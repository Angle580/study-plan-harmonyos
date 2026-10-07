/**
 * 数据模型定义
 * 大学生自习学习规划助手
 */

// 任务优先级
export enum Priority {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH'
}

// 学习任务
export interface Task {
  id: string;
  title: string;
  subject: string;
  dateStr: string; // YYYY-MM-DD
  priority: Priority;
  done: boolean;
  createdAt: number;
}

// 课程
export interface Course {
  id: string;
  name: string;
  teacher: string;
  location: string;
  weekday: number; // 1-7 周一到周日
  section: number; // 1-5 第几节大节
  colorIndex: number; // 用于卡片配色
}

// 专注记录
export interface FocusRecord {
  id: string;
  taskId: string;
  taskTitle: string;
  subject: string;
  minutes: number;
  dateStr: string; // YYYY-MM-DD
  timestamp: number;
}

// 用户资料
export interface UserProfile {
  name: string;
  school: string;
  major: string;
  signature: string;
  dailyGoalMinutes: number;
}

// 工厂函数（禁止使用 Object.assign）
export function createTask(title: string, subject: string, dateStr: string, priority: Priority): Task {
  const t: Task = {
    id: 't_' + Date.now().toString() + '_' + Math.floor(Math.random() * 1000).toString(),
    title: title,
    subject: subject,
    dateStr: dateStr,
    priority: priority,
    done: false,
    createdAt: Date.now()
  };
  return t;
}

export function createCourse(name: string, teacher: string, location: string,
  weekday: number, section: number, colorIndex: number): Course {
  const c: Course = {
    id: 'c_' + Date.now().toString() + '_' + Math.floor(Math.random() * 1000).toString(),
    name: name,
    teacher: teacher,
    location: location,
    weekday: weekday,
    section: section,
    colorIndex: colorIndex
  };
  return c;
}

export function createFocusRecord(taskId: string, taskTitle: string, subject: string, minutes: number): FocusRecord {
  const now = new Date();
  const r: FocusRecord = {
    id: 'f_' + Date.now().toString() + '_' + Math.floor(Math.random() * 1000).toString(),
    taskId: taskId,
    taskTitle: taskTitle,
    subject: subject,
    minutes: minutes,
    dateStr: formatDate(now),
    timestamp: Date.now()
  };
  return r;
}

export function createDefaultProfile(): UserProfile {
  const p: UserProfile = {
    name: '同学',
    school: '阳光大学',
    major: '计算机科学与技术',
    signature: '专注当下，稳步前行',
    dailyGoalMinutes: 120
  };
  return p;
}

// 日期格式化工具 YYYY-MM-DD
export function formatDate(d: Date): string {
  const y: number = d.getFullYear();
  const m: number = d.getMonth() + 1;
  const day: number = d.getDate();
  const mm: string = m < 10 ? '0' + m.toString() : m.toString();
  const dd: string = day < 10 ? '0' + day.toString() : day.toString();
  return y.toString() + '-' + mm + '-' + dd;
}

// 优先级中文标签
export function priorityLabel(p: Priority): string {
  if (p === Priority.HIGH) {
    return '高';
  } else if (p === Priority.MEDIUM) {
    return '中';
  }
  return '低';
}

// 优先级颜色
export function priorityColor(p: Priority): string {
  if (p === Priority.HIGH) {
    return '#FF7A59';
  } else if (p === Priority.MEDIUM) {
    return '#FFB74D';
  }
  return '#7FC8A9';
}

// 星期中文
export function weekdayLabel(w: number): string {
  const names: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  if (w >= 1 && w <= 7) {
    return names[w - 1];
  }
  return '';
}

// 大节时间段
export function sectionLabel(s: number): string {
  const times: string[] = ['08:00 - 09:40', '10:00 - 11:40', '14:00 - 15:40', '16:00 - 17:40', '19:00 - 20:40'];
  if (s >= 1 && s <= 5) {
    return times[s - 1];
  }
  return '';
}

export function sectionName(s: number): string {
  const names: string[] = ['第一大节', '第二大节', '第三大节', '第四大节', '第五大节'];
  if (s >= 1 && s <= 5) {
    return names[s - 1];
  }
  return '';
}

// 预设科目
export class Subjects {
  static readonly list: string[] = ['数学', '英语', '计算机', '物理', '语文', '专业课', '其他'];
}

// 专注时长选项（分钟）
export class FocusDurations {
  static readonly list: number[] = [15, 25, 45, 60];
}
