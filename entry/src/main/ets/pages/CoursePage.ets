import { router, promptAction } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { DataStore } from '../common/DataStore';
import { EventHub } from '../common/EventHub';
import { Course, weekdayLabel, sectionLabel, sectionName } from '../common/Models';
import { CourseDialog } from '../dialogs/CourseDialog';

@Entry
@Component
struct CoursePage {
  @State selectedDay: number = 1;
  @State dayCourses: Course[] = [];
  @State refreshKey: number = 0;

  @State dlgHeader: string = '添加课程';
  @State editId: string = '';
  @State dlgName: string = '';
  @State dlgTeacher: string = '';
  @State dlgLocation: string = '';
  @State dlgWeekday: number = 1;
  @State dlgSection: number = 1;
  private subId: number = 0;

  private courseDialog: CustomDialogController = new CustomDialogController({
    builder: CourseDialog({
      dialogTitle: this.dlgHeader,
      initName: this.dlgName,
      initTeacher: this.dlgTeacher,
      initLocation: this.dlgLocation,
      initWeekday: this.dlgWeekday,
      initSection: this.dlgSection,
      onConfirm: (name: string, teacher: string, location: string, weekday: number, section: number): void => {
        if (this.editId.length > 0) {
          DataStore.getInstance().updateCourse(this.editId, name, teacher, location, weekday, section);
        } else {
          DataStore.getInstance().addCourse(name, teacher, location, weekday, section, this.pickColorIndex());
        }
      }
    }),
    customStyle: true,
    alignment: DialogAlignment.Center,
    autoCancel: true
  });

  aboutToAppear(): void {
    this.selectedDay = this.todayWeekday();
    this.loadData();
    this.subId = EventHub.getInstance().subscribe(() => {
      this.loadData();
    });
  }

  aboutToDisappear(): void {
    EventHub.getInstance().unsubscribe(this.subId);
  }

  private todayWeekday(): number {
    const js: number = new Date().getDay();
    return js === 0 ? 7 : js;
  }

  private pickColorIndex(): number {
    return DataStore.getInstance().getCourses().length % Theme.courseColors.length;
  }

  private loadData(): void {
    const list = DataStore.getInstance().getCoursesByWeekday(this.selectedDay);
    list.sort((a: Course, b: Course) => a.section - b.section);
    this.dayCourses = list;
    this.refreshKey = this.refreshKey + 1;
  }

  private openAdd(): void {
    this.dlgHeader = '添加课程';
    this.editId = '';
    this.dlgName = '';
    this.dlgTeacher = '';
    this.dlgLocation = '';
    this.dlgWeekday = this.selectedDay;
    this.dlgSection = 1;
    this.courseDialog.open();
  }

  private openEdit(item: Course): void {
    this.dlgHeader = '编辑课程';
    this.editId = item.id;
    this.dlgName = item.name;
    this.dlgTeacher = item.teacher;
    this.dlgLocation = item.location;
    this.dlgWeekday = item.weekday;
    this.dlgSection = item.section;
    this.courseDialog.open();
  }

  private confirmDelete(item: Course): void {
    AlertDialog.show({
      title: '删除课程',
      message: '确定删除「' + item.name + '」吗？',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        fontColor: Theme.textBody,
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: Theme.danger,
        action: () => {
          DataStore.getInstance().deleteCourse(item.id);
          promptAction.showToast({ message: '已删除' });
        }
      }
    });
  }

  private days: number[] = [1, 2, 3, 4, 5, 6, 7];

  build() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor(Theme.textTitle)
          .onClick(() => {
            router.back();
          })
        Text('我的课程表')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.textTitle)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Image($r('app.media.ic_add'))
          .width(24)
          .height(24)
          .fillColor(Theme.primary)
          .onClick(() => {
            this.openAdd();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .backgroundColor(Theme.card)
      .border({ width: 1, color: Theme.border })

      // 星期选择
      Scroll() {
        Row() {
          ForEach(this.days, (d: number) => {
            Column() {
              Text(weekdayLabel(d))
                .fontSize(14)
                .fontColor(this.selectedDay === d ? '#FFFFFF' : Theme.textBody)
            }
            .padding({ left: 16, right: 16, top: 9, bottom: 9 })
            .backgroundColor(this.selectedDay === d ? Theme.primary : Theme.card)
            .border({ width: 1, color: this.selectedDay === d ? Theme.primary : Theme.border })
            .borderRadius(Theme.radiusM)
            .margin({ right: 10 })
            .onClick(() => {
              this.selectedDay = d;
              this.loadData();
            })
          }, (d: number) => 'day' + d + '_' + this.selectedDay)
        }
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .margin({ top: 14, bottom: 6 })

      // 课程列表
      List({ space: 12 }) {
        ForEach(this.dayCourses, (item: Course) => {
          ListItem() {
            this.courseCard(item)
          }
        }, (item: Course) => item.id + '_' + this.refreshKey)

        if (this.dayCourses.length === 0) {
          ListItem() {
            Column() {
              Text(weekdayLabel(this.selectedDay) + '没有课程')
                .fontSize(14)
                .fontColor(Theme.textHint)
              Text('点击右上角添加课程')
                .fontSize(12)
                .fontColor(Theme.textHint)
                .margin({ top: 8 })
            }
            .width('100%')
            .padding({ top: 80, bottom: 80 })
            .justifyContent(FlexAlign.Center)
          }
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8 })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  courseCard(item: Course) {
    Row() {
      Column() {
        Text(sectionName(item.section).substring(1, 3))
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.courseTextColors[item.colorIndex % Theme.courseTextColors.length])
      }
      .width(54)
      .height(54)
      .borderRadius(Theme.radiusM)
      .backgroundColor(Theme.courseColors[item.colorIndex % Theme.courseColors.length])
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(item.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.textTitle)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row() {
          Image($r('app.media.ic_clock')).width(13).height(13).fillColor(Theme.textHint)
          Text(sectionLabel(item.section))
            .fontSize(12)
            .fontColor(Theme.textHint)
            .margin({ left: 4 })
        }
        .margin({ top: 7 })
        Row() {
          Image($r('app.media.ic_location')).width(13).height(13).fillColor(Theme.textHint)
          Text(item.location.length > 0 ? item.location : '未设置')
            .fontSize(12)
            .fontColor(Theme.textHint)
            .margin({ left: 4 })
          Image($r('app.media.ic_teacher')).width(13).height(13).fillColor(Theme.textHint).margin({ left: 12 })
          Text(item.teacher.length > 0 ? item.teacher : '未设置')
            .fontSize(12)
            .fontColor(Theme.textHint)
            .margin({ left: 4 })
        }
        .margin({ top: 5 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })

      Column() {
        Image($r('app.media.ic_edit'))
          .width(20)
          .height(20)
          .fillColor(Theme.textHint)
          .onClick(() => {
            this.openEdit(item);
          })
        Image($r('app.media.ic_delete'))
          .width(20)
          .height(20)
          .fillColor(Theme.danger)
          .margin({ top: 16 })
          .onClick(() => {
            this.confirmDelete(item);
          })
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.card)
    .borderRadius(Theme.radiusM)
    .border({ width: 1, color: Theme.border })
  }
}
