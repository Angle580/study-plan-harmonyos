import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { DataStore } from '../common/DataStore';
import { EventHub } from '../common/EventHub';
import { Task, Course, weekdayLabel, sectionLabel, priorityColor, priorityLabel, formatDate } from '../common/Models';

export type SwitchTabCallback = (index: number) => void;

@Component
export struct HomeView {
  onSwitchTab: SwitchTabCallback = () => {};

  @State userName: string = '';
  @State greeting: string = '';
  @State dateText: string = '';
  @State todayFocus: number = 0;
  @State goalMinutes: number = 120;
  @State pendingCount: number = 0;
  @State doneCount: number = 0;
  @State todayTasks: Task[] = [];
  @State todayCourses: Course[] = [];
  @State refreshKey: number = 0;
  private subId: number = 0;

  aboutToAppear(): void {
    this.loadData();
    this.subId = EventHub.getInstance().subscribe(() => {
      this.loadData();
    });
  }

  aboutToDisappear(): void {
    EventHub.getInstance().unsubscribe(this.subId);
  }

  private loadData(): void {
    const store = DataStore.getInstance();
    const profile = store.getProfile();
    this.userName = profile.name;
    this.goalMinutes = profile.dailyGoalMinutes;
    this.todayFocus = store.getTodayFocusMinutes();
    this.pendingCount = store.getPendingTaskCount();
    this.doneCount = store.getCompletedTaskCount();
    this.todayTasks = store.getTodayTasks();
    const weekday: number = this.todayWeekday();
    this.todayCourses = store.getCoursesByWeekday(weekday);
    this.greeting = this.computeGreeting();
    this.dateText = this.computeDateText();
    this.refreshKey = this.refreshKey + 1;
  }

  private todayWeekday(): number {
    const js: number = new Date().getDay(); // 0 周日
    return js === 0 ? 7 : js;
  }

  private computeGreeting(): string {
    const h: number = new Date().getHours();
    if (h < 6) {
      return '夜深了';
    } else if (h < 11) {
      return '早上好';
    } else if (h < 14) {
      return '中午好';
    } else if (h < 18) {
      return '下午好';
    }
    return '晚上好';
  }

  private computeDateText(): string {
    const d = new Date();
    return formatDate(d) + '  ' + weekdayLabel(this.todayWeekday());
  }

  private goalProgress(): number {
    if (this.goalMinutes <= 0) {
      return 0;
    }
    const p: number = this.todayFocus / this.goalMinutes;
    return p > 1 ? 1 : p;
  }

  build() {
    Scroll() {
      Column() {
        // 顶部问候 + 横幅
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.home_banner'))
            .width('100%')
            .height(168)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radiusL)
          Column()
            .width('100%')
            .height(168)
            .borderRadius(Theme.radiusL)
            .linearGradient({
              angle: 180,
              colors: [['#00000000', 0.35], ['#00000066', 1.0]]
            })
          Column() {
            Text(this.greeting + '，' + this.userName)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text(this.dateText)
              .fontSize(13)
              .fontColor('#F2FFFB')
              .margin({ top: 6 })
          }
          .alignItems(HorizontalAlign.Start)
          .padding(18)
        }
        .width('100%')
        .height(168)
        .borderRadius(Theme.radiusL)

        // 今日专注目标卡片
        Column() {
          Row() {
            Column() {
              Text('今日专注')
                .fontSize(13)
                .fontColor(Theme.textHint)
              Row() {
                Text(this.todayFocus.toString())
                  .fontSize(30)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.primaryDeep)
                Text(' 分钟')
                  .fontSize(14)
                  .fontColor(Theme.textBody)
                  .margin({ bottom: 4 })
              }
              .alignItems(VerticalAlign.Bottom)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Button() {
              Row() {
                Image($r('app.media.ic_play'))
                  .width(16)
                  .height(16)
                  .fillColor('#FFFFFF')
                Text('开始自习')
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .margin({ left: 6 })
              }
            }
            .backgroundColor(Theme.primary)
            .borderRadius(Theme.radiusM)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .onClick(() => {
              this.onSwitchTab(2);
            })
          }
          .width('100%')

          // 进度条
          Stack({ alignContent: Alignment.Start }) {
            Row()
              .width('100%')
              .height(8)
              .borderRadius(4)
              .backgroundColor(Theme.primaryLight)
            Row()
              .width(this.goalProgress() * 100 + '%')
              .height(8)
              .borderRadius(4)
              .backgroundColor(Theme.primary)
          }
          .width('100%')
          .margin({ top: 16 })

          Text('目标 ' + this.goalMinutes.toString() + ' 分钟 · 已完成 ' +
            Math.round(this.goalProgress() * 100).toString() + '%')
            .fontSize(12)
            .fontColor(Theme.textHint)
            .width('100%')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding(18)
        .backgroundColor(Theme.card)
        .borderRadius(Theme.radiusL)
        .border({ width: 1, color: Theme.border })
        .margin({ top: 16 })

        // 数据概览
        Row() {
          this.statCell(this.pendingCount.toString(), '待办任务', Theme.accent)
          Blank().width(12)
          this.statCell(this.doneCount.toString(), '已完成', Theme.primary)
          Blank().width(12)
          this.statCell(this.todayCourses.length.toString(), '今日课程', '#3A6CC7')
        }
        .width('100%')
        .margin({ top: 12 })

        // 快捷入口
        Row() {
          this.entryCell($r('app.media.ic_grid'), '课程表', '#3A6CC7', '#E8F0FE', (): void => {
            router.pushUrl({ url: 'pages/CoursePage' });
          })
          Blank().width(12)
          this.entryCell($r('app.media.ic_task'), '我的计划', Theme.accent, Theme.accentLight, (): void => {
            this.onSwitchTab(1);
          })
        }
        .width('100%')
        .margin({ top: 12 })

        // 今日任务
        Row() {
          Text('今日任务')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.textTitle)
          Blank()
          Text('查看全部')
            .fontSize(13)
            .fontColor(Theme.primary)
            .onClick(() => {
              this.onSwitchTab(1);
            })
        }
        .width('100%')
        .margin({ top: 22, bottom: 12 })

        if (this.todayTasks.length === 0) {
          this.emptyHint('今天还没有任务，去添加一个吧')
        } else {
          ForEach(this.todayTasks, (item: Task) => {
            this.taskRow(item)
          }, (item: Task) => item.id + '_' + (item.done ? '1' : '0') + '_' + this.refreshKey)
        }

        // 今日课程
        Row() {
          Text('今日课程')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.textTitle)
          Blank()
          Text('课程表')
            .fontSize(13)
            .fontColor(Theme.primary)
            .onClick(() => {
              router.pushUrl({ url: 'pages/CoursePage' });
            })
        }
        .width('100%')
        .margin({ top: 22, bottom: 12 })

        if (this.todayCourses.length === 0) {
          this.emptyHint('今天没有课程安排')
        } else {
          ForEach(this.todayCourses, (item: Course) => {
            this.courseRow(item)
          }, (item: Course) => item.id + '_' + this.refreshKey)
        }

        Blank().height(20)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }

  @Builder
  statCell(value: string, label: string, color: string) {
    Column() {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(12)
        .fontColor(Theme.textHint)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor(Theme.card)
    .borderRadius(Theme.radiusM)
    .border({ width: 1, color: Theme.border })
  }

  @Builder
  entryCell(icon: Resource, label: string, iconColor: string, bg: string, action: () => void) {
    Row() {
      Column() {
        Image(icon)
          .width(22)
          .height(22)
          .fillColor(iconColor)
      }
      .width(44)
      .height(44)
      .borderRadius(Theme.radiusM)
      .backgroundColor(bg)
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(label)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.textTitle)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      Image($r('app.media.ic_arrow_right'))
        .width(18)
        .height(18)
        .fillColor(Theme.textHint)
    }
    .layoutWeight(1)
    .padding(14)
    .backgroundColor(Theme.card)
    .borderRadius(Theme.radiusM)
    .border({ width: 1, color: Theme.border })
    .onClick(action)
  }

  @Builder
  taskRow(item: Task) {
    Row() {
      Column()
        .width(8)
        .height(36)
        .borderRadius(4)
        .backgroundColor(priorityColor(item.priority))
      Column() {
        Text(item.title)
          .fontSize(15)
          .fontColor(item.done ? Theme.textHint : Theme.textTitle)
          .decoration({ type: item.done ? TextDecorationType.LineThrough : TextDecorationType.None })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(item.subject + ' · 优先级' + priorityLabel(item.priority))
          .fontSize(12)
          .fontColor(Theme.textHint)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      Column() {
        if (item.done) {
          Image($r('app.media.ic_check'))
            .width(16)
            .height(16)
            .fillColor('#FFFFFF')
        }
      }
      .width(24)
      .height(24)
      .borderRadius(12)
      .backgroundColor(item.done ? Theme.primary : Theme.card)
      .border({ width: item.done ? 0 : 2, color: Theme.border })
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        DataStore.getInstance().toggleTask(item.id);
      })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.card)
    .borderRadius(Theme.radiusM)
    .border({ width: 1, color: Theme.border })
    .margin({ bottom: 10 })
  }

  @Builder
  courseRow(item: Course) {
    Row() {
      Column() {
        Image($r('app.media.ic_book'))
          .width(20)
          .height(20)
          .fillColor(Theme.courseTextColors[item.colorIndex % Theme.courseTextColors.length])
      }
      .width(42)
      .height(42)
      .borderRadius(Theme.radiusM)
      .backgroundColor(Theme.courseColors[item.colorIndex % Theme.courseColors.length])
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(item.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.textTitle)
        Text(sectionLabel(item.section) + ' · ' + item.location)
          .fontSize(12)
          .fontColor(Theme.textHint)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Theme.card)
    .borderRadius(Theme.radiusM)
    .border({ width: 1, color: Theme.border })
    .margin({ bottom: 10 })
  }

  @Builder
  emptyHint(text: string) {
    Column() {
      Text(text)
        .fontSize(13)
        .fontColor(Theme.textHint)
    }
    .width('100%')
    .padding({ top: 24, bottom: 24 })
    .backgroundColor(Theme.card)
    .borderRadius(Theme.radiusM)
    .border({ width: 1, color: Theme.border })
    .justifyContent(FlexAlign.Center)
  }
}
