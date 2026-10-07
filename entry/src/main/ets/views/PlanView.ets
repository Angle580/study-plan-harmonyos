import { promptAction } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { DataStore } from '../common/DataStore';
import { EventHub } from '../common/EventHub';
import { Task, Priority, priorityColor, priorityLabel } from '../common/Models';
import { TaskDialog } from '../dialogs/TaskDialog';

@Component
export struct PlanView {
  @State allTasks: Task[] = [];
  @State filter: number = 0; // 0 全部 1 待办 2 已完成
  @State refreshKey: number = 0;

  // 对话框相关
  @State dlgHeader: string = '新建任务';
  @State editId: string = '';
  @State dlgTitle: string = '';
  @State dlgSubject: string = '数学';
  @State dlgDate: string = '';
  @State dlgPriority: Priority = Priority.MEDIUM;
  private subId: number = 0;

  private taskDialog: CustomDialogController = new CustomDialogController({
    builder: TaskDialog({
      dialogTitle: this.dlgHeader,
      initTitle: this.dlgTitle,
      initSubject: this.dlgSubject,
      initDate: this.dlgDate,
      initPriority: this.dlgPriority,
      onConfirm: (title: string, subject: string, dateStr: string, priority: Priority): void => {
        if (this.editId.length > 0) {
          DataStore.getInstance().updateTask(this.editId, title, subject, dateStr, priority);
        } else {
          DataStore.getInstance().addTask(title, subject, dateStr, priority);
        }
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
    const list = DataStore.getInstance().getTasks();
    list.sort((a: Task, b: Task) => {
      if (a.done !== b.done) {
        return a.done ? 1 : -1;
      }
      if (a.dateStr !== b.dateStr) {
        return a.dateStr < b.dateStr ? -1 : 1;
      }
      return this.priorityRank(b.priority) - this.priorityRank(a.priority);
    });
    this.allTasks = list;
    this.refreshKey = this.refreshKey + 1;
  }

  private priorityRank(p: Priority): number {
    if (p === Priority.HIGH) {
      return 3;
    } else if (p === Priority.MEDIUM) {
      return 2;
    }
    return 1;
  }

  private filteredTasks(): Task[] {
    if (this.filter === 1) {
      return this.allTasks.filter((t: Task) => !t.done);
    } else if (this.filter === 2) {
      return this.allTasks.filter((t: Task) => t.done);
    }
    return this.allTasks;
  }

  private openAdd(): void {
    this.dlgHeader = '新建任务';
    this.editId = '';
    this.dlgTitle = '';
    this.dlgSubject = '数学';
    this.dlgDate = '';
    this.dlgPriority = Priority.MEDIUM;
    this.taskDialog.open();
  }

  private openEdit(item: Task): void {
    this.dlgHeader = '编辑任务';
    this.editId = item.id;
    this.dlgTitle = item.title;
    this.dlgSubject = item.subject;
    this.dlgDate = item.dateStr;
    this.dlgPriority = item.priority;
    this.taskDialog.open();
  }

  private confirmDelete(item: Task): void {
    AlertDialog.show({
      title: '删除任务',
      message: '确定要删除「' + item.title + '」吗？',
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
          DataStore.getInstance().deleteTask(item.id);
          promptAction.showToast({ message: '已删除' });
        }
      }
    });
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Column() {
          Text('学习计划')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.textTitle)
          Text('管理你的学习任务')
            .fontSize(13)
            .fontColor(Theme.textHint)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button() {
          Row() {
            Image($r('app.media.ic_add'))
              .width(18)
              .height(18)
              .fillColor('#FFFFFF')
            Text('新建')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .margin({ left: 4 })
          }
        }
        .backgroundColor(Theme.primary)
        .borderRadius(Theme.radiusM)
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .onClick(() => {
          this.openAdd();
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })

      // 过滤器
      Row() {
        this.filterChip('全部', 0)
        Blank().width(10)
        this.filterChip('待办', 1)
        Blank().width(10)
        this.filterChip('已完成', 2)
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })

      // 列表
      List({ space: 10 }) {
        ForEach(this.filteredTasks(), (item: Task) => {
          ListItem() {
            this.taskCard(item)
          }
        }, (item: Task) => item.id + '_' + (item.done ? '1' : '0') + '_' + this.refreshKey)

        if (this.filteredTasks().length === 0) {
          ListItem() {
            Column() {
              Text('暂无任务')
                .fontSize(14)
                .fontColor(Theme.textHint)
            }
            .width('100%')
            .padding({ top: 60, bottom: 60 })
            .justifyContent(FlexAlign.Center)
          }
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  filterChip(label: string, value: number) {
    Text(label)
      .fontSize(14)
      .fontColor(this.filter === value ? '#FFFFFF' : Theme.textBody)
      .backgroundColor(this.filter === value ? Theme.primary : Theme.card)
      .border({ width: 1, color: this.filter === value ? Theme.primary : Theme.border })
      .borderRadius(Theme.radiusM)
      .padding({ left: 18, right: 18, top: 8, bottom: 8 })
      .onClick(() => {
        this.filter = value;
      })
  }

  @Builder
  taskCard(item: Task) {
    Row() {
      // 完成勾选
      Column() {
        if (item.done) {
          Image($r('app.media.ic_check'))
            .width(18)
            .height(18)
            .fillColor('#FFFFFF')
        }
      }
      .width(26)
      .height(26)
      .borderRadius(13)
      .backgroundColor(item.done ? Theme.primary : Theme.card)
      .border({ width: item.done ? 0 : 2, color: Theme.border })
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        DataStore.getInstance().toggleTask(item.id);
      })

      Column() {
        Text(item.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(item.done ? Theme.textHint : Theme.textTitle)
          .decoration({ type: item.done ? TextDecorationType.LineThrough : TextDecorationType.None })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row() {
          Text(item.subject)
            .fontSize(11)
            .fontColor(Theme.primaryDeep)
            .backgroundColor(Theme.primaryLight)
            .borderRadius(6)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          Text('优先级' + priorityLabel(item.priority))
            .fontSize(11)
            .fontColor(priorityColor(item.priority))
            .backgroundColor(Theme.cardSoft)
            .borderRadius(6)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .margin({ left: 8 })
          Text(item.dateStr.substring(5))
            .fontSize(11)
            .fontColor(Theme.textHint)
            .margin({ left: 8 })
        }
        .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      Image($r('app.media.ic_edit'))
        .width(20)
        .height(20)
        .fillColor(Theme.textHint)
        .margin({ right: 14 })
        .onClick(() => {
          this.openEdit(item);
        })
      Image($r('app.media.ic_delete'))
        .width(20)
        .height(20)
        .fillColor(Theme.danger)
        .onClick(() => {
          this.confirmDelete(item);
        })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.card)
    .borderRadius(Theme.radiusM)
    .border({ width: 1, color: Theme.border })
  }
}
