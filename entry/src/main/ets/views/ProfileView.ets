import { router, promptAction } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { DataStore } from '../common/DataStore';
import { EventHub } from '../common/EventHub';
import { Priority } from '../common/Models';
import { ProfileDialog } from '../dialogs/ProfileDialog';

@Component
export struct ProfileView {
  @State userName: string = '';
  @State school: string = '';
  @State major: string = '';
  @State signature: string = '';
  @State goalMinutes: number = 120;
  @State totalMinutes: number = 0;
  @State doneTasks: number = 0;
  @State courseCount: number = 0;
  @State refreshKey: number = 0;
  private subId: number = 0;

  private profileDialog: CustomDialogController = new CustomDialogController({
    builder: ProfileDialog({
      initName: this.userName,
      initSchool: this.school,
      initMajor: this.major,
      initSignature: this.signature,
      initGoal: this.goalMinutes,
      onConfirm: (name: string, school: string, major: string, signature: string, goal: number): void => {
        DataStore.getInstance().updateProfile(name, school, major, signature, goal);
        promptAction.showToast({ message: '资料已更新' });
      }
    }),
    customStyle: true,
    alignment: DialogAlignment.Center,
    autoCancel: true
  });

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
    const p = store.getProfile();
    this.userName = p.name;
    this.school = p.school;
    this.major = p.major;
    this.signature = p.signature;
    this.goalMinutes = p.dailyGoalMinutes;
    this.totalMinutes = store.getTotalFocusMinutes();
    this.doneTasks = store.getCompletedTaskCount();
    this.courseCount = store.getCourses().length;
    this.refreshKey = this.refreshKey + 1;
  }

  private confirmClear(): void {
    AlertDialog.show({
      title: '清空学习数据',
      message: '将清空全部任务、课程和专注记录，个人资料保留。此操作不可恢复。',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        fontColor: Theme.textBody,
        action: () => {}
      },
      secondaryButton: {
        value: '清空',
        fontColor: Theme.danger,
        action: () => {
          DataStore.getInstance().clearAllData();
          promptAction.showToast({ message: '已清空学习数据' });
        }
      }
    });
  }

  build() {
    Scroll() {
      Column() {
        // 资料卡
        Column() {
          Row() {
            Image($r('app.media.avatar'))
              .width(68)
              .height(68)
              .borderRadius(34)
              .objectFit(ImageFit.Cover)
              .border({ width: 2, color: '#FFFFFF' })
            Column() {
              Text(this.userName)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.textTitle)
              Text(this.signature)
                .fontSize(13)
                .fontColor(Theme.textBody)
                .margin({ top: 6 })
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: 16 })

            Image($r('app.media.ic_edit'))
              .width(22)
              .height(22)
              .fillColor(Theme.primary)
              .onClick(() => {
                this.profileDialog.open();
              })
          }
          .width('100%')

          Row() {
            Row() {
              Image($r('app.media.ic_school')).width(16).height(16).fillColor(Theme.textHint)
              Text(this.school).fontSize(13).fontColor(Theme.textBody).margin({ left: 6 })
            }
            .layoutWeight(1)
            Row() {
              Image($r('app.media.ic_book')).width(16).height(16).fillColor(Theme.textHint)
              Text(this.major).fontSize(13).fontColor(Theme.textBody).margin({ left: 6 })
                .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: 18 })
        }
        .width('100%')
        .padding(20)
        .backgroundColor(Theme.card)
        .borderRadius(Theme.radiusL)
        .border({ width: 1, color: Theme.border })

        // 数据概览
        Row() {
          this.summaryCell(this.totalMinutes.toString(), '专注分钟', Theme.primary)
          this.divider()
          this.summaryCell(this.doneTasks.toString(), '完成任务', Theme.accent)
          this.divider()
          this.summaryCell(this.courseCount.toString(), '课程数', '#3A6CC7')
        }
        .width('100%')
        .padding({ top: 18, bottom: 18 })
        .backgroundColor(Theme.card)
        .borderRadius(Theme.radiusL)
        .border({ width: 1, color: Theme.border })
        .margin({ top: 12 })

        // 每日目标
        Row() {
          Row() {
            Column() {
              Image($r('app.media.ic_target')).width(20).height(20).fillColor(Theme.primaryDeep)
            }
            .width(40).height(40).borderRadius(Theme.radiusM)
            .backgroundColor(Theme.primaryLight).justifyContent(FlexAlign.Center)
            Column() {
              Text('每日专注目标').fontSize(15).fontColor(Theme.textTitle)
              Text(this.goalMinutes.toString() + ' 分钟 / 天').fontSize(12).fontColor(Theme.textHint).margin({ top: 3 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
            .layoutWeight(1)
          }
          .layoutWeight(1)
          Image($r('app.media.ic_edit')).width(18).height(18).fillColor(Theme.textHint)
            .onClick(() => {
              this.profileDialog.open();
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Theme.card)
        .borderRadius(Theme.radiusL)
        .border({ width: 1, color: Theme.border })
        .margin({ top: 12 })

        // 菜单
        Column() {
          this.menuItem($r('app.media.ic_grid'), '我的课程表', '#3A6CC7', '#E8F0FE', (): void => {
            router.pushUrl({ url: 'pages/CoursePage' });
          })
          Divider().color(Theme.divider).margin({ left: 52 })
          this.menuItem($r('app.media.ic_delete'), '清空学习数据', Theme.danger, Theme.accentLight, (): void => {
            this.confirmClear();
          })
        }
        .width('100%')
        .backgroundColor(Theme.card)
        .borderRadius(Theme.radiusL)
        .border({ width: 1, color: Theme.border })
        .margin({ top: 12 })

        // 关于
        Column() {
          Text('关于应用')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.textTitle)
            .width('100%')
          Text('自习规划助手 v1.0\n帮助大学生规划学习任务、专注自习、管理课程并记录成长。所有数据保存在本地设备。')
            .fontSize(12)
            .fontColor(Theme.textHint)
            .width('100%')
            .margin({ top: 8 })
            .lineHeight(20)
        }
        .alignItems(HorizontalAlign.Start)
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

  @Builder
  summaryCell(value: string, label: string, color: string) {
    Column() {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(12)
        .fontColor(Theme.textHint)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
  }

  @Builder
  divider() {
    Column()
      .width(1)
      .height(30)
      .backgroundColor(Theme.divider)
  }

  @Builder
  menuItem(icon: Resource, label: string, iconColor: string, bg: string, action: () => void) {
    Row() {
      Column() {
        Image(icon).width(18).height(18).fillColor(iconColor)
      }
      .width(36).height(36).borderRadius(Theme.radiusS)
      .backgroundColor(bg).justifyContent(FlexAlign.Center)
      Text(label)
        .fontSize(15)
        .fontColor(Theme.textTitle)
        .layoutWeight(1)
        .margin({ left: 16 })
      Image($r('app.media.ic_arrow_right')).width(18).height(18).fillColor(Theme.textHint)
    }
    .width('100%')
    .padding(16)
    .onClick(action)
  }
}
