import { Theme } from '../common/Theme';
import { DataStore } from '../common/DataStore';
import { EventHub } from '../common/EventHub';
import { weekdayLabel } from '../common/Models';

interface BarItem {
  label: string;
  minutes: number;
}

interface SubjectStat {
  name: string;
  minutes: number;
}

@Component
export struct StatsView {
  @State totalMinutes: number = 0;
  @State totalSessions: number = 0;
  @State doneTasks: number = 0;
  @State pendingTasks: number = 0;
  @State weekBars: BarItem[] = [];
  @State subjectStats: SubjectStat[] = [];
  @State maxWeek: number = 0;
  @State maxSubject: number = 0;
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
    this.totalMinutes = store.getTotalFocusMinutes();
    this.totalSessions = store.getFocusRecords().length;
    this.doneTasks = store.getCompletedTaskCount();
    this.pendingTasks = store.getPendingTaskCount();

    const week: number[] = store.getWeekFocusMinutes();
    const now = new Date();
    const bars: BarItem[] = [];
    let maxW: number = 1;
    for (let i = 0; i < 7; i++) {
      const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - (6 - i));
      const jsW: number = d.getDay();
      const w: number = jsW === 0 ? 7 : jsW;
      const item: BarItem = { label: weekdayLabel(w).substring(1), minutes: week[i] };
      bars.push(item);
      if (week[i] > maxW) {
        maxW = week[i];
      }
    }
    this.weekBars = bars;
    this.maxWeek = maxW;

    const map = store.getSubjectFocusMap();
    const stats: SubjectStat[] = [];
    let maxS: number = 1;
    map.forEach((v: number, k: string) => {
      const s: SubjectStat = { name: k, minutes: v };
      stats.push(s);
      if (v > maxS) {
        maxS = v;
      }
    });
    stats.sort((a: SubjectStat, b: SubjectStat) => b.minutes - a.minutes);
    this.subjectStats = stats;
    this.maxSubject = maxS;
    this.refreshKey = this.refreshKey + 1;
  }

  private hoursText(): string {
    const h: number = Math.floor(this.totalMinutes / 60);
    const m: number = this.totalMinutes % 60;
    if (h > 0) {
      return h.toString() + ' 小时 ' + m.toString() + ' 分';
    }
    return m.toString() + ' 分钟';
  }

  build() {
    Scroll() {
      Column() {
        Column() {
          Text('学习统计')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.textTitle)
          Text('记录你的成长轨迹')
            .fontSize(13)
            .fontColor(Theme.textHint)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ bottom: 16 })

        // 累计专注总览
        Column() {
          Text('累计专注时长')
            .fontSize(13)
            .fontColor('#EAFBF5')
          Text(this.hoursText())
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ top: 8 })
          Row() {
            Text('共 ' + this.totalSessions.toString() + ' 次专注')
              .fontSize(13)
              .fontColor('#EAFBF5')
          }
          .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding(20)
        .borderRadius(Theme.radiusL)
        .linearGradient({
          angle: 135,
          colors: [[Theme.primary, 0.0], [Theme.primaryDeep, 1.0]]
        })

        // 任务统计
        Row() {
          this.miniStat(this.doneTasks.toString(), '已完成任务', Theme.primary)
          Blank().width(12)
          this.miniStat(this.pendingTasks.toString(), '待办任务', Theme.accent)
        }
        .width('100%')
        .margin({ top: 12 })

        // 最近7天专注
        Column() {
          Text('最近 7 天专注（分钟）')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.textTitle)
            .width('100%')

          Row() {
            ForEach(this.weekBars, (item: BarItem) => {
              Column() {
                Text(item.minutes > 0 ? item.minutes.toString() : '')
                  .fontSize(10)
                  .fontColor(Theme.textHint)
                  .margin({ bottom: 4 })
                Column()
                  .width(18)
                  .height(this.barHeight(item.minutes))
                  .borderRadius(6)
                  .backgroundColor(item.minutes > 0 ? Theme.primary : Theme.divider)
                Text(item.label)
                  .fontSize(11)
                  .fontColor(Theme.textHint)
                  .margin({ top: 8 })
              }
              .justifyContent(FlexAlign.End)
              .layoutWeight(1)
            }, (item: BarItem) => item.label + '_' + item.minutes + '_' + this.refreshKey)
          }
          .width('100%')
          .height(160)
          .alignItems(VerticalAlign.Bottom)
          .margin({ top: 16 })
        }
        .width('100%')
        .padding(18)
        .backgroundColor(Theme.card)
        .borderRadius(Theme.radiusL)
        .border({ width: 1, color: Theme.border })
        .margin({ top: 12 })

        // 科目分布
        Column() {
          Text('科目专注分布')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.textTitle)
            .width('100%')
            .margin({ bottom: 4 })

          if (this.subjectStats.length === 0) {
            Text('还没有专注记录')
              .fontSize(13)
              .fontColor(Theme.textHint)
              .width('100%')
              .margin({ top: 16, bottom: 16 })
              .textAlign(TextAlign.Center)
          } else {
            ForEach(this.subjectStats, (item: SubjectStat) => {
              Column() {
                Row() {
                  Text(item.name)
                    .fontSize(13)
                    .fontColor(Theme.textBody)
                    .layoutWeight(1)
                  Text(item.minutes.toString() + ' 分')
                    .fontSize(13)
                    .fontColor(Theme.textHint)
                }
                .width('100%')
                Stack({ alignContent: Alignment.Start }) {
                  Row().width('100%').height(8).borderRadius(4).backgroundColor(Theme.cardSoft)
                  Row()
                    .width(this.subjectRatio(item.minutes) + '%')
                    .height(8)
                    .borderRadius(4)
                    .backgroundColor(Theme.accent)
                }
                .width('100%')
                .margin({ top: 6 })
              }
              .width('100%')
              .margin({ top: 14 })
            }, (item: SubjectStat) => item.name + '_' + item.minutes + '_' + this.refreshKey)
          }
        }
        .width('100%')
        .padding(18)
        .backgroundColor(Theme.card)
        .borderRadius(Theme.radiusL)
        .border({ width: 1, color: Theme.border })
        .margin({ top: 12 })

        Blank().height(20)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }

  private barHeight(minutes: number): number {
    const maxH: number = 120;
    if (this.maxWeek <= 0) {
      return 4;
    }
    const h: number = (minutes / this.maxWeek) * maxH;
    return minutes > 0 ? Math.max(h, 6) : 4;
  }

  private subjectRatio(minutes: number): number {
    if (this.maxSubject <= 0) {
      return 0;
    }
    return Math.round((minutes / this.maxSubject) * 100);
  }

  @Builder
  miniStat(value: string, label: string, color: string) {
    Column() {
      Text(value)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(12)
        .fontColor(Theme.textHint)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ top: 18, bottom: 18 })
    .backgroundColor(Theme.card)
    .borderRadius(Theme.radiusM)
    .border({ width: 1, color: Theme.border })
  }
}
