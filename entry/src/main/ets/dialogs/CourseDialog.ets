import { Theme } from '../common/Theme';
import { weekdayLabel, sectionName } from '../common/Models';

export type CourseConfirmCallback = (name: string, teacher: string, location: string, weekday: number, section: number) => void;

@CustomDialog
export struct CourseDialog {
  controller: CustomDialogController = new CustomDialogController({ builder: CourseDialog() });
  dialogTitle: string = '添加课程';
  initName: string = '';
  initTeacher: string = '';
  initLocation: string = '';
  initWeekday: number = 1;
  initSection: number = 1;
  onConfirm: CourseConfirmCallback = () => {};

  @State nameVal: string = '';
  @State teacherVal: string = '';
  @State locationVal: string = '';
  @State weekdayVal: number = 1;
  @State sectionVal: number = 1;
  @State errorTip: string = '';

  private weekdays: number[] = [1, 2, 3, 4, 5, 6, 7];
  private sections: number[] = [1, 2, 3, 4, 5];

  aboutToAppear(): void {
    this.nameVal = this.initName;
    this.teacherVal = this.initTeacher;
    this.locationVal = this.initLocation;
    this.weekdayVal = this.initWeekday;
    this.sectionVal = this.initSection;
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

      TextInput({ text: this.nameVal, placeholder: '课程名称' })
        .fontSize(15)
        .backgroundColor(Theme.cardSoft)
        .borderRadius(Theme.radiusS)
        .padding({ left: 12, right: 12 })
        .height(46)
        .width('100%')
        .onChange((v: string) => {
          this.nameVal = v;
          this.errorTip = '';
        })

      Row() {
        TextInput({ text: this.teacherVal, placeholder: '任课教师' })
          .fontSize(15)
          .backgroundColor(Theme.cardSoft)
          .borderRadius(Theme.radiusS)
          .padding({ left: 12, right: 12 })
          .height(46)
          .layoutWeight(1)
          .onChange((v: string) => {
            this.teacherVal = v;
          })
        Blank().width(10)
        TextInput({ text: this.locationVal, placeholder: '上课地点' })
          .fontSize(15)
          .backgroundColor(Theme.cardSoft)
          .borderRadius(Theme.radiusS)
          .padding({ left: 12, right: 12 })
          .height(46)
          .layoutWeight(1)
          .onChange((v: string) => {
            this.locationVal = v;
          })
      }
      .width('100%')
      .margin({ top: 12 })

      Text('星期')
        .fontSize(13)
        .fontColor(Theme.textHint)
        .width('100%')
        .margin({ top: 16, bottom: 8 })
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.weekdays, (w: number) => {
          Text(weekdayLabel(w))
            .fontSize(13)
            .fontColor(this.weekdayVal === w ? '#FFFFFF' : Theme.textBody)
            .backgroundColor(this.weekdayVal === w ? Theme.primary : Theme.cardSoft)
            .borderRadius(Theme.radiusS)
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.weekdayVal = w;
            })
        }, (w: number) => 'w' + w + '_' + this.weekdayVal)
      }
      .width('100%')

      Text('节次')
        .fontSize(13)
        .fontColor(Theme.textHint)
        .width('100%')
        .margin({ top: 8, bottom: 8 })
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.sections, (s: number) => {
          Text(sectionName(s))
            .fontSize(13)
            .fontColor(this.sectionVal === s ? '#FFFFFF' : Theme.textBody)
            .backgroundColor(this.sectionVal === s ? Theme.primary : Theme.cardSoft)
            .borderRadius(Theme.radiusS)
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.sectionVal = s;
            })
        }, (s: number) => 's' + s + '_' + this.sectionVal)
      }
      .width('100%')

      if (this.errorTip.length > 0) {
        Text(this.errorTip)
          .fontSize(12)
          .fontColor(Theme.danger)
          .width('100%')
          .margin({ top: 12 })
      }

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
            if (this.nameVal.trim().length === 0) {
              this.errorTip = '请填写课程名称';
              return;
            }
            this.onConfirm(this.nameVal.trim(), this.teacherVal.trim(), this.locationVal.trim(),
              this.weekdayVal, this.sectionVal);
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
