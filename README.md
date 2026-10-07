# 大学生自习学习规划助手

基于 HarmonyOS NEXT (ArkTS) 的大学生学习规划与自习管理应用。

## 功能

- **首页**：学习进度概览、今日课程、待办任务
- **课程表**：周课表管理，支持增删改课程
- **自习计时**：番茄钟倒计时、学习任务清单
- **统计**：近7天学习时长统计
- **我的**：个人信息、学习目标设置

## 技术栈

- HarmonyOS NEXT Stage 模型
- ArkTS / ArkUI 声明式开发
- Preferences 本地持久化存储
- DevEco Studio 6.0.2

## 项目结构

```
entry/src/main/ets/
├── pages/          # 页面
├── views/          # 视图组件
├── common/         # DataStore、EventHub、Models、Theme
└── dialogs/        # 弹窗组件
```

## 开发环境

- Windows 11
- DevEco Studio 6.0.2
- HarmonyOS SDK 6.0.2(22)
- 鸿蒙模拟器 nova 16 Pro
