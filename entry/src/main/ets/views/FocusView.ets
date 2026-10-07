import { promptAction } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { DataStore } from '../common/DataStore';
import { EventHub } from '../common/EventHub';
import { Task, FocusRecord, FocusDurations } from '../common/Models';

@Component
export struct FocusView {
  @State durationMin: number = 25;
  @State totalSeconds: number = 25 * 60;
  @State remainSeconds: number = 25 * 60;
  @State running: boolean = false;
  @State started: boolean = false;
  @State selectedTaskId: string = '';
  @State selectedTaskTitle: string = '自由专注';
  @State selectedSubject: string = '自习';
  @State pendingTasks: Task[] = [];
  @State todayRecords: FocusRecord[] = [];
  @State todayTotal: number = 0;
  @State refreshKey: number = 0;
  private timerId: number = -1;
  private subId: number = 0;

  aboutToAppear(): void {
    this.loadData();
    this.subId = EventHub.getInstance().subscribe(() => {
      this.loadData();
    });
  }

  aboutToDisappear(): void {
    this.clearTimer();
    EventHub.getInstance().unsubscribe(this.subId);
  }

  private loadData(): void {
    const store = DataStore.getInstance();
    this.pendingTasks = store.getTodayTasks().filter((t: Task) => !t.done);
    this.todayRecords = store.getFocusByDate(this.todayStr());
    this.todayTotal = store.getTodayFocusMinutes();
    // 若已选任务被删除或完成，重置选择
    if (this.selectedTaskId.length > 0) {
      const exist = this.pendingTasks.some((t: Task) => t.id === this.selectedTaskId);
      if (!exist) {
        this.resetSelection();
      }
    }
    this.refreshKey = this.refreshKey + 1;
  }

  private todayStr(): string {
    const d = new Date();
    const y = d.getFullYear();
    const m = d.getMonth() + 1;
    const day = d.getDate();
    const mm = m < 10 ? '0' + m.toString() : m.toString();
    const dd = day < 10 ? '0' + day.toString() : day.toString();
    return y.toString() + '-' + mm + '-' + dd;
  }

  private resetSelection(): void {
    this.selectedTaskId = '';
    this.selectedTaskTitle = '自由专注';
    this.selectedSubject = '自习';
  }

  private clearTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private startTimer(): void {
    this.running = true;
    this.started = true;
    this.timerId = setInterval(() => {
      if (this.remainSeconds > 0) {
        this.remainSeconds = this.remainSeconds - 1;
      }
      if (this.remainSeconds <= 0) {
        this.completeFocus();
      }
    }, 1000);
  }

  private pauseTimer(): void {
    this.running = false;
    this.clearTimer();
  }

  private completeFocus(): void {
    this.clearTimer();
    const elapsedMin: number = this.durationMin;
    DataStore.getInstance().addFocusRecord(this.selectedTaskId, this.selectedTaskTitle, this.selectedSubject, elapsedMin);
    promptAction.showToast({ message: '完成 ' + elapsedMin.toString() + ' 分钟专注，真棒！' });
    this.resetTimer();
  }

  private stopTimer(): void {
    this.clearTimer();
    const elapsedSec: number = this.totalSeconds - this.remainSeconds;
    const elapsedMin: number = Math.floor(elapsedSec / 60);
    if (elapsedMin >= 1) {
      DataStore.getInstance().addFocusRecord(this.selectedTaskId, this.selectedTaskTitle, this.selectedSubject, elapsedMin);
      promptAction.showToast({ message: '已记录 ' + elapsedMin.toString() + ' 分钟' });
    } else {
      promptAction.showToast({ message: '专注不足 1 分钟，未记录' });
    }
    this.resetTimer();
  }

  private resetTimer(): void {
    this.running = false;
    this.started = false;
    this.remainSeconds = this.totalSeconds;
  }

  private setDuration(min: number): void {
    if (this.started) {
      return;
    }
    this.durationMin = min;
    this.totalSeconds = min * 60;
    this.remainSeconds = min * 60;
  }

  private timeText(): string {
    const m: number = Math.floor(this.remainSeconds / 60);
    const s: number = this.remainSeconds % 60;
    const mm: string = m < 10 ? '0' + m.toString() : m.toString();
    const ss: string = s < 10 ? '0' + s.toString() : s.toString();
    return mm + ':' + ss;
  }

  private progressValue(): number {
    return this.totalSeconds - this.remainSeconds;
  }

  build() {
    Scroll() {
      Column() {
        // 标题
        Column() {
          Text('专注自习')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.textTitle)
          Text('番茄钟 · 今日已专注 ' + this.todayTotal.toString() + ' 分钟')
            .fontSize(13)
            .fontColor(Theme.textHint)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ bottom: 16 })

        // 计时圆环
        Stack({ alignContent: Alignment.Center }) {
          Progress({ value: this.progressValue(), total: this.totalSeconds, type: ProgressType.Ring })
            .width(240)
            .height(240)
            .color(Theme.primary)
            .style({ strokeWidth: 14 })
            .backgroundColor(Theme.primaryLight)
          Column() {
            Text(this.timeText())
              .fontSize(52)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.textTitle)
            Text(this.running ? '专注中' : (this.started ? '已暂停' : '准备开始'))
              .fontSize(14)
              .fontColor(Theme.textHint)
              .margin({ top: 4 })
            Text(this.selectedTaskTitle)
              .fontSize(13)
              .fontColor(Theme.primaryDeep)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 10 })
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .backgroundColor(Theme.primaryLight)
              .borderRadius(10)
          }
        }
        .width('100%')
        .height(260)
        .margin({ top: 8, bottom: 8 })

        // 时长选择
        if (!this.started) {
          Row() {
            ForEach(FocusDurations.list, (d: number) => {
              Text(d.toString() + ' 分')
                .fontSize(14)
                .fontColor(this.durationMin === d ? '#FFFFFF' : Theme.textBody)
                .backgroundColor(this.durationMin === d ? Theme.primary : Theme.card)
                .border({ width: 1, color: this.durationMin === d ? Theme.primary : Theme.border })
                .borderRadius(Theme.radiusM)
                .padding({ top: 10, bottom: 10 })
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .margin({ right: 8 })
                .onClick(() => {
                  this.setDuration(d);
                })
            }, (d: number) => 'd' + d + '_' + this.durationMin)
          }
          .width('100%')
          .margin({ top: 8 })
        }

        // 控制按钮
        Row() {
          if (!this.started) {
            Button() {
              Row() {
                Image($r('app.media.ic_play')).width(20).height(20).fillColor('#FFFFFF')
                Text('开始专注').fontSize(16).fontColor('#FFFFFF').margin({ left: 8 })
              }
            }
            .backgroundColor(Theme.primary)
            .borderRadius(Theme.radiusM)
            .height(52)
            .width('100%')
            .onClick(() => {
              this.startTimer();
            })
          } else {
            Button() {
              Row() {
                Image(this.running ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
                  .width(20).height(20).fillColor('#FFFFFF')
                Text(this.running ? '暂停' : '继续').fontSize(16).fontColor('#FFFFFF').margin({ left: 6 })
              }
            }
            .backgroundColor(Theme.primary)
            .borderRadius(Theme.radiusM)
            .height(52)
            .layoutWeight(1)
            .onClick(() => {
              if (this.running) {
                this.pauseTimer();
              } else {
                this.startTimer();
              }
            })
            Blank().width(12)
            Button() {
              Row() {
                Image($r('app.media.ic_stop')).width(18).height(18).fillColor(Theme.danger)
                Text('结束').fontSize(16).fontColor(Theme.danger).margin({ left: 6 })
              }
            }
            .backgroundColor(Theme.accentLight)
            .borderRadius(Theme.radiusM)
            .height(52)
            .layoutWeight(1)
            .onClick(() => {
              this.stopTimer();
            })
          }
        }
        .width('100%')
        .margin({ top: 18 })

        // 选择关联任务
        if (!this.started) {
          Column() {
            Image($r('app.media.focus_illus'))
              .width('100%')
              .height(150)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radiusL)
            Text('专注当下，每一分钟都算数')
              .fontSize(13)
              .fontColor(Theme.textHint)
              .margin({ top: 10 })
          }
          .width('100%')
          .margin({ top: 24 })

          Text('关联任务')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.textTitle)
            .width('100%')
            .margin({ top: 20, bottom: 10 })

          Column() {
            Row() {
              Text('自由专注（不关联任务）')
                .fontSize(14)
                .fontColor(this.selectedTaskId.length === 0 ? Theme.primaryDeep : Theme.textBody)
                .layoutWeight(1)
              if (this.selectedTaskId.length === 0) {
                Image($r('app.media.ic_check')).width(18).height(18).fillColor(Theme.primary)
              }
            }
            .width('100%')
            .padding(14)
            .backgroundColor(this.selectedTaskId.length === 0 ? Theme.primaryLight : Theme.card)
            .borderRadius(Theme.radiusM)
            .border({ width: 1, color: Theme.border })
            .onClick(() => {
              this.resetSelection();
            })

            ForEach(this.pendingTasks, (t: Task) => {
              Row() {
                Column() {
                  Text(t.title)
                    .fontSize(14)
                    .fontColor(this.selectedTaskId === t.id ? Theme.primaryDeep : Theme.textTitle)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(t.subject)
                    .fontSize(12)
                    .fontColor(Theme.textHint)
                    .margin({ top: 3 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                if (this.selectedTaskId === t.id) {
                  Image($r('app.media.ic_check')).width(18).height(18).fillColor(Theme.primary)
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor(this.selectedTaskId === t.id ? Theme.primaryLight : Theme.card)
              .borderRadius(Theme.radiusM)
              .border({ width: 1, color: Theme.border })
              .margin({ top: 10 })
              .onClick(() => {
                this.selectedTaskId = t.id;
                this.selectedTaskTitle = t.title;
                this.selectedSubject = t.subject;
              })
            }, (t: Task) => t.id + '_' + this.selectedTaskId + '_' + this.refreshKey)
          }
          .width('100%')
        }

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
}
