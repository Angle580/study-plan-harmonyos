import { Theme } from '../common/Theme';

export type ProfileConfirmCallback = (name: string, school: string, major: string, signature: string, goal: number) => void;

@CustomDialog
export struct ProfileDialog {
  controller: CustomDialogController = new CustomDialogController({ builder: ProfileDialog() });
  initName: string = '';
  initSchool: string = '';
  initMajor: string = '';
  initSignature: string = '';
  initGoal: number = 120;
  onConfirm: ProfileConfirmCallback = () => {};

  @State nameVal: string = '';
  @State schoolVal: string = '';
  @State majorVal: string = '';
  @State signatureVal: string = '';
  @State goalVal: number = 120;
  @State errorTip: string = '';

  private goals: number[] = [60, 90, 120, 180, 240];

  aboutToAppear(): void {
    this.nameVal = this.initName;
    this.schoolVal = this.initSchool;
    this.majorVal = this.initMajor;
    this.signatureVal = this.initSignature;
    this.goalVal = this.initGoal;
  }

  build() {
    Column() {
      Text('编辑资料')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.textTitle)
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 18 })

      TextInput({ text: this.nameVal, placeholder: '昵称' })
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

      TextInput({ text: this.schoolVal, placeholder: '学校' })
        .fontSize(15)
        .backgroundColor(Theme.cardSoft)
        .borderRadius(Theme.radiusS)
        .padding({ left: 12, right: 12 })
        .height(46)
        .width('100%')
        .margin({ top: 12 })
        .onChange((v: string) => {
          this.schoolVal = v;
        })

      TextInput({ text: this.majorVal, placeholder: '专业' })
        .fontSize(15)
        .backgroundColor(Theme.cardSoft)
        .borderRadius(Theme.radiusS)
        .padding({ left: 12, right: 12 })
        .height(46)
        .width('100%')
        .margin({ top: 12 })
        .onChange((v: string) => {
          this.majorVal = v;
        })

      TextInput({ text: this.signatureVal, placeholder: '个性签名' })
        .fontSize(15)
        .backgroundColor(Theme.cardSoft)
        .borderRadius(Theme.radiusS)
        .padding({ left: 12, right: 12 })
        .height(46)
        .width('100%')
        .margin({ top: 12 })
        .onChange((v: string) => {
          this.signatureVal = v;
        })

      Text('每日专注目标（分钟）')
        .fontSize(13)
        .fontColor(Theme.textHint)
        .width('100%')
        .margin({ top: 16, bottom: 8 })
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.goals, (g: number) => {
          Text(g.toString())
            .fontSize(13)
            .fontColor(this.goalVal === g ? '#FFFFFF' : Theme.textBody)
            .backgroundColor(this.goalVal === g ? Theme.primary : Theme.cardSoft)
            .borderRadius(Theme.radiusS)
            .padding({ left: 16, right: 16, top: 7, bottom: 7 })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.goalVal = g;
            })
        }, (g: number) => 'g' + g + '_' + this.goalVal)
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
              this.errorTip = '请填写昵称';
              return;
            }
            this.onConfirm(this.nameVal.trim(), this.schoolVal.trim(), this.majorVal.trim(),
              this.signatureVal.trim(), this.goalVal);
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
