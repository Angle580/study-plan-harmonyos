/**
 * 本地数据仓库（单例）
 * 使用 Preferences 本地缓存进行持久化，内存中保存数据副本供页面读取。
 * 提供任务、课程、专注记录、用户资料的增删改查，并在变更后通知所有页面同步。
 */
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Task, Course, FocusRecord, UserProfile, Priority,
  createTask, createCourse, createFocusRecord, createDefaultProfile, formatDate } from './Models';
import { EventHub } from './EventHub';

const DOMAIN = 0x0001;
const STORE_NAME = 'study_assistant_store';

class Keys {
  static readonly TASKS: string = 'tasks';
  static readonly COURSES: string = 'courses';
  static readonly FOCUS: string = 'focus_records';
  static readonly PROFILE: string = 'profile';
  static readonly SEEDED: string = 'seeded_v1';
}

export class DataStore {
  private static instance: DataStore | null = null;
  private pref: preferences.Preferences | null = null;
  private tasks: Task[] = [];
  private courses: Course[] = [];
  private focusRecords: FocusRecord[] = [];
  private profile: UserProfile = createDefaultProfile();
  private inited: boolean = false;

  static getInstance(): DataStore {
    if (DataStore.instance === null) {
      DataStore.instance = new DataStore();
    }
    return DataStore.instance;
  }

  // 在 Ability onCreate 中调用，加载本地缓存
  init(context: common.UIAbilityContext): void {
    if (this.inited) {
      return;
    }
    try {
      this.pref = preferences.getPreferencesSync(context, { name: STORE_NAME });
      this.loadAll();
      const seeded: boolean = this.pref.getSync(Keys.SEEDED, false) as boolean;
      if (!seeded) {
        this.seedDemoData();
        this.pref.putSync(Keys.SEEDED, true);
        this.pref.flush();
      }
      this.inited = true;
      hilog.info(DOMAIN, 'DataStore', '%{public}s', 'DataStore inited');
    } catch (err) {
      hilog.error(DOMAIN, 'DataStore', 'init failed: %{public}s', JSON.stringify(err));
    }
  }

  private loadAll(): void {
    if (this.pref === null) {
      return;
    }
    const tasksStr: string = this.pref.getSync(Keys.TASKS, '[]') as string;
    const coursesStr: string = this.pref.getSync(Keys.COURSES, '[]') as string;
    const focusStr: string = this.pref.getSync(Keys.FOCUS, '[]') as string;
    const profileStr: string = this.pref.getSync(Keys.PROFILE, '') as string;
    this.tasks = JSON.parse(tasksStr) as Task[];
    this.courses = JSON.parse(coursesStr) as Course[];
    this.focusRecords = JSON.parse(focusStr) as FocusRecord[];
    if (profileStr.length > 0) {
      this.profile = JSON.parse(profileStr) as UserProfile;
    }
  }

  private persist(key: string, value: string): void {
    if (this.pref === null) {
      return;
    }
    try {
      this.pref.putSync(key, value);
      this.pref.flush();
    } catch (err) {
      hilog.error(DOMAIN, 'DataStore', 'persist failed: %{public}s', JSON.stringify(err));
    }
  }

  private notify(): void {
    EventHub.getInstance().emit();
  }

  // ============ 任务 ============
  getTasks(): Task[] {
    return this.tasks.slice();
  }

  getTasksByDate(dateStr: string): Task[] {
    return this.tasks.filter((t: Task) => t.dateStr === dateStr);
  }

  getTodayTasks(): Task[] {
    return this.getTasksByDate(formatDate(new Date()));
  }

  addTask(title: string, subject: string, dateStr: string, priority: Priority): void {
    const t: Task = createTask(title, subject, dateStr, priority);
    this.tasks.push(t);
    this.persist(Keys.TASKS, JSON.stringify(this.tasks));
    this.notify();
  }

  updateTask(id: string, title: string, subject: string, dateStr: string, priority: Priority): void {
    for (let i = 0; i < this.tasks.length; i++) {
      if (this.tasks[i].id === id) {
        this.tasks[i].title = title;
        this.tasks[i].subject = subject;
        this.tasks[i].dateStr = dateStr;
        this.tasks[i].priority = priority;
        break;
      }
    }
    this.persist(Keys.TASKS, JSON.stringify(this.tasks));
    this.notify();
  }

  toggleTask(id: string): void {
    for (let i = 0; i < this.tasks.length; i++) {
      if (this.tasks[i].id === id) {
        this.tasks[i].done = !this.tasks[i].done;
        break;
      }
    }
    this.persist(Keys.TASKS, JSON.stringify(this.tasks));
    this.notify();
  }

  deleteTask(id: string): void {
    this.tasks = this.tasks.filter((t: Task) => t.id !== id);
    this.persist(Keys.TASKS, JSON.stringify(this.tasks));
    this.notify();
  }

  // ============ 课程 ============
  getCourses(): Course[] {
    return this.courses.slice();
  }

  getCoursesByWeekday(weekday: number): Course[] {
    return this.courses.filter((c: Course) => c.weekday === weekday);
  }

  addCourse(name: string, teacher: string, location: string, weekday: number, section: number, colorIndex: number): void {
    const c: Course = createCourse(name, teacher, location, weekday, section, colorIndex);
    this.courses.push(c);
    this.persist(Keys.COURSES, JSON.stringify(this.courses));
    this.notify();
  }

  updateCourse(id: string, name: string, teacher: string, location: string, weekday: number, section: number): void {
    for (let i = 0; i < this.courses.length; i++) {
      if (this.courses[i].id === id) {
        this.courses[i].name = name;
        this.courses[i].teacher = teacher;
        this.courses[i].location = location;
        this.courses[i].weekday = weekday;
        this.courses[i].section = section;
        break;
      }
    }
    this.persist(Keys.COURSES, JSON.stringify(this.courses));
    this.notify();
  }

  deleteCourse(id: string): void {
    this.courses = this.courses.filter((c: Course) => c.id !== id);
    this.persist(Keys.COURSES, JSON.stringify(this.courses));
    this.notify();
  }

  // ============ 专注记录 ============
  getFocusRecords(): FocusRecord[] {
    return this.focusRecords.slice();
  }

  getFocusByDate(dateStr: string): FocusRecord[] {
    return this.focusRecords.filter((r: FocusRecord) => r.dateStr === dateStr);
  }

  addFocusRecord(taskId: string, taskTitle: string, subject: string, minutes: number): void {
    const r: FocusRecord = createFocusRecord(taskId, taskTitle, subject, minutes);
    this.focusRecords.push(r);
    this.persist(Keys.FOCUS, JSON.stringify(this.focusRecords));
    this.notify();
  }

  deleteFocusRecord(id: string): void {
    this.focusRecords = this.focusRecords.filter((r: FocusRecord) => r.id !== id);
    this.persist(Keys.FOCUS, JSON.stringify(this.focusRecords));
    this.notify();
  }

  // 今日已专注分钟数
  getTodayFocusMinutes(): number {
    const today: string = formatDate(new Date());
    let sum: number = 0;
    this.focusRecords.forEach((r: FocusRecord) => {
      if (r.dateStr === today) {
        sum = sum + r.minutes;
      }
    });
    return sum;
  }

  getTotalFocusMinutes(): number {
    let sum: number = 0;
    this.focusRecords.forEach((r: FocusRecord) => {
      sum = sum + r.minutes;
    });
    return sum;
  }

  // 最近7天每天专注分钟（返回长度7，索引0为6天前，6为今天）
  getWeekFocusMinutes(): number[] {
    const result: number[] = [0, 0, 0, 0, 0, 0, 0];
    const now = new Date();
    for (let i = 0; i < 7; i++) {
      const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - (6 - i));
      const ds: string = formatDate(d);
      let sum: number = 0;
      this.focusRecords.forEach((r: FocusRecord) => {
        if (r.dateStr === ds) {
          sum = sum + r.minutes;
        }
      });
      result[i] = sum;
    }
    return result;
  }

  // ============ 用户资料 ============
  getProfile(): UserProfile {
    const p: UserProfile = {
      name: this.profile.name,
      school: this.profile.school,
      major: this.profile.major,
      signature: this.profile.signature,
      dailyGoalMinutes: this.profile.dailyGoalMinutes
    };
    return p;
  }

  updateProfile(name: string, school: string, major: string, signature: string, dailyGoalMinutes: number): void {
    this.profile.name = name;
    this.profile.school = school;
    this.profile.major = major;
    this.profile.signature = signature;
    this.profile.dailyGoalMinutes = dailyGoalMinutes;
    this.persist(Keys.PROFILE, JSON.stringify(this.profile));
    this.notify();
  }

  // ============ 统计辅助 ============
  getCompletedTaskCount(): number {
    return this.tasks.filter((t: Task) => t.done).length;
  }

  getPendingTaskCount(): number {
    return this.tasks.filter((t: Task) => !t.done).length;
  }

  // 各科目专注分钟分布
  getSubjectFocusMap(): Map<string, number> {
    const map: Map<string, number> = new Map();
    this.focusRecords.forEach((r: FocusRecord) => {
      const cur: number = map.has(r.subject) ? (map.get(r.subject) as number) : 0;
      map.set(r.subject, cur + r.minutes);
    });
    return map;
  }

  // 清空全部学习数据（保留用户资料）
  clearAllData(): void {
    this.tasks = [];
    this.courses = [];
    this.focusRecords = [];
    this.persist(Keys.TASKS, JSON.stringify(this.tasks));
    this.persist(Keys.COURSES, JSON.stringify(this.courses));
    this.persist(Keys.FOCUS, JSON.stringify(this.focusRecords));
    this.notify();
  }

  // ============ 初始演示数据 ============
  private seedDemoData(): void {
    const today: string = formatDate(new Date());
    const tomorrow: string = formatDate(new Date(Date.now() + 24 * 3600 * 1000));
    this.tasks = [];
    this.tasks.push(createTask('复习高等数学第三章', '数学', today, Priority.HIGH));
    this.tasks.push(createTask('背诵英语四级核心词汇', '英语', today, Priority.MEDIUM));
    this.tasks.push(createTask('完成数据结构课后习题', '计算机', today, Priority.MEDIUM));
    this.tasks.push(createTask('整理线性代数笔记', '数学', tomorrow, Priority.LOW));

    this.courses = [];
    this.courses.push(createCourse('高等数学', '李教授', '教一 301', 1, 1, 0));
    this.courses.push(createCourse('大学英语', '王老师', '外语楼 205', 1, 3, 1));
    this.courses.push(createCourse('数据结构', '陈老师', '实验楼 401', 2, 2, 2));
    this.courses.push(createCourse('线性代数', '赵教授', '教二 102', 3, 1, 3));
    this.courses.push(createCourse('计算机网络', '孙老师', '实验楼 502', 4, 4, 4));
    this.courses.push(createCourse('体育', '刘教练', '田径场', 5, 2, 5));

    const r1: FocusRecord = createFocusRecord('', '复习高等数学第三章', '数学', 45);
    this.focusRecords = [r1];

    this.persist(Keys.TASKS, JSON.stringify(this.tasks));
    this.persist(Keys.COURSES, JSON.stringify(this.courses));
    this.persist(Keys.FOCUS, JSON.stringify(this.focusRecords));
    this.persist(Keys.PROFILE, JSON.stringify(this.profile));
  }
}
