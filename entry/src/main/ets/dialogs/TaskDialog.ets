import { Theme } from '../common/Theme';
import { Priority, Subjects, priorityLabel, priorityColor, formatDate } from '../common/Models';

export type TaskConfirmCallback = (title: string, subject: string, dateStr: string, priority: Priority) => void;

interface DateOption {
  label: string;
  value: string;
}

@CustomDialog
export struct TaskDialog {
  controller: CustomDialogController = new CustomDialogController({ builder: TaskDialog() });
  dialogTitle: string = '新建任务';
  initTitle: string = '';
  initSubject: string = '数学';
  initDate: string = '';
  initPriority: Priority = Priority.MEDIUM;
  onConfirm: TaskConfirmCallback = () => {};

  @State titleVal: string = '';
  @State subjectVal: string = '数学';
  @State dateVal: string = '';
  @State priorityVal: Priority = Priority.MEDIUM;
  @State errorTip: string = '';

  private priorities: Priority[] = [Priority.HIGH, Priority.MEDIUM, Priority.LOW];

  aboutToAppear(): void {
    this.titleVal = this.initTitle;
    this.subjectVal = this.initSubject;
    this.priorityVal = this.initPriority;
    if (this.initDate.length > 0) {
      this.dateVal = this.initDate;
    } else {
      this.dateVal = formatDate(new Date());
    }
  }

  private dateOptions(): DateOption[] {
    const today = new Date();
    const opts: DateOption[] = [];
    const labels: string[] = ['今天', '明天', '后天'];
    for (let i = 0; i < 3; i++) {
      const d = new Date(today.getFullYear(), today.getMonth(), today.getDate() + i);
      const o: DateOption = { label: labels[i], value: formatDate(d) };
      opts.push(o);
    }
    return opts;
  }

  build() {
    Column() {
      Text(this.dialogTitle)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.textTitle)
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 18 })

      // 任务标题
      Text('任务内容')
        .fontSize(13)
        .fontColor(Theme.textHint)
        .width('100%')
        .margin({ bottom: 6 })
      TextInput({ text: this.titleVal, placeholder: '例如：复习高等数学第三章' })
        .fontSize(15)
        .fontColor(Theme.textTitle)
        .backgroundColor(Theme.cardSoft)
        .borderRadius(Theme.radiusS)
        .padding({ left: 12, right: 12 })
        .height(46)
        .width('100%')
        .onChange((v: string) => {
          this.titleVal = v;
          this.errorTip = '';
        })

      // 科目
      Text('科目')
        .fontSize(13)
        .fontColor(Theme.textHint)
        .width('100%')
        .margin({ top: 16, bottom: 8 })
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(Subjects.list, (sub: string) => {
          Text(sub)
            .fontSize(13)
            .fontColor(this.subjectVal === sub ? '#FFFFFF' : Theme.textBody)
            .backgroundColor(this.subjectVal === sub ? Theme.primary : Theme.cardSoft)
            .borderRadius(Theme.radiusS)
            .padding({ left: 14, right: 14, top: 7, bottom: 7 })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.subjectVal = sub;
            })
        }, (sub: string) => sub + '_' + this.subjectVal)
      }
      .width('100%')

      // 日期
      Text('计划日期')
        .fontSize(13)
        .fontColor(Theme.textHint)
        .width('100%')
        .margin({ top: 8, bottom: 8 })
      Row() {
        ForEach(this.dateOptions(), (opt: DateOption) => {
          Text(opt.label)
            .fontSize(13)
            .fontColor(this.dateVal === opt.value ? '#FFFFFF' : Theme.textBody)
            .backgroundColor(this.dateVal === opt.value ? Theme.primary : Theme.cardSoft)
            .borderRadius(Theme.radiusS)
            .padding({ top: 8, bottom: 8 })
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .margin({ right: 8 })
            .onClick(() => {
              this.dateVal = opt.value;
            })
        }, (opt: DateOption) => opt.value + '_' + this.dateVal)
      }
      .width('100%')

      // 优先级
      Text('优先级')
        .fontSize(13)
        .fontColor(Theme.textHint)
        .width('100%')
        .margin({ top: 16, bottom: 8 })
      Row() {
        ForEach(this.priorities, (p: Priority) => {
          Text(priorityLabel(p))
            .fontSize(13)
            .fontColor(this.priorityVal === p ? '#FFFFFF' : priorityColor(p))
            .backgroundColor(this.priorityVal === p ? priorityColor(p) : Theme.cardSoft)
            .borderRadius(Theme.radiusS)
            .padding({ top: 8, bottom: 8 })
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .margin({ right: 8 })
            .onClick(() => {
              this.priorityVal = p;
            })
        }, (p: Priority) => p + '_' + this.priorityVal)
      }
      .width('100%')

      if (this.errorTip.length > 0) {
        Text(this.errorTip)
          .fontSize(12)
          .fontColor(Theme.danger)
          .width('100%')
          .margin({ top: 12 })
      }

      // 操作按钮
      Row() {
        Button('取消')
          .fontSize(15)
          .fontColor(Theme.textBody)
          .backgroundColor(Theme.cardSoft)
          .layoutWeight(1)
          .height(46)
          .onClick(() => {
            this.controller.close();
          })
        Blank().width(12)
        Button('保存')
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor(Theme.primary)
          .layoutWeight(1)
          .height(46)
          .onClick(() => {
            if (this.titleVal.trim().length === 0) {
              this.errorTip = '请填写任务内容';
              return;
            }
            this.onConfirm(this.titleVal.trim(), this.subjectVal, this.dateVal, this.priorityVal);
            this.controller.close();
          })
      }
      .width('100%')
      .margin({ top: 22 })
    }
    .width('100%')
    .padding(22)
    .backgroundColor(Theme.card)
    .borderRadius(Theme.radiusL)
  }
}
