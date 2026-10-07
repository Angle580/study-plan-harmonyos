import { Theme } from '../common/Theme';
import { HomeView } from '../views/HomeView';
import { PlanView } from '../views/PlanView';
import { FocusView } from '../views/FocusView';
import { StatsView } from '../views/StatsView';
import { ProfileView } from '../views/ProfileView';

interface TabInfo {
  title: string;
  icon: Resource;
  index: number;
}

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;

  build() {
    Column() {
      Tabs({ index: this.currentIndex }) {
        TabContent() {
          HomeView({ onSwitchTab: (i: number): void => {
            this.currentIndex = i;
          } })
        }
        .tabBar(this.bottomTab('首页', $r('app.media.ic_home'), 0))

        TabContent() {
          PlanView()
        }
        .tabBar(this.bottomTab('计划', $r('app.media.ic_task'), 1))

        TabContent() {
          FocusView()
        }
        .tabBar(this.bottomTab('自习', $r('app.media.ic_focus'), 2))

        TabContent() {
          StatsView()
        }
        .tabBar(this.bottomTab('统计', $r('app.media.ic_stats'), 3))

        TabContent() {
          ProfileView()
        }
        .tabBar(this.bottomTab('我的', $r('app.media.ic_profile'), 4))
      }
      .barPosition(BarPosition.End)
      .vertical(false)
      .scrollable(false)
      .animationDuration(200)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .backgroundColor(Theme.bg)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg)
  }

  @Builder
  bottomTab(title: string, icon: Resource, index: number) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === index ? Theme.primary : Theme.textHint)
      Text(title)
        .fontSize(11)
        .fontColor(this.currentIndex === index ? Theme.primary : Theme.textHint)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .margin({ top: 4 })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Theme.card)
  }
}
