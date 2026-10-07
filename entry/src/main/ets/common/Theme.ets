/**
 * 全局主题：清新亮色系（米白 + 薄荷绿 + 暖橙）
 * 禁止暗黑色系
 */
export class Theme {
  // 主色：薄荷绿
  static readonly primary: string = '#3FB99B';
  static readonly primaryDeep: string = '#2E9B81';
  static readonly primaryLight: string = '#E5F5F0';
  // 辅助色：暖橙
  static readonly accent: string = '#FF9F5A';
  static readonly accentLight: string = '#FFF0E5';
  // 背景
  static readonly bg: string = '#F5F7FA';
  static readonly card: string = '#FFFFFF';
  static readonly cardSoft: string = '#F7FAF9';
  // 文字
  static readonly textTitle: string = '#2B3A39';
  static readonly textBody: string = '#4A5A59';
  static readonly textHint: string = '#9AA8A6';
  // 边框/分割线
  static readonly border: string = '#EDF1F0';
  static readonly divider: string = '#F0F3F2';
  // 状态色
  static readonly success: string = '#3FB99B';
  static readonly warning: string = '#FFB74D';
  static readonly danger: string = '#FF7A59';

  // 课程卡片配色（亮色系）
  static readonly courseColors: string[] = ['#E5F5F0', '#FFF0E5', '#E8F0FE', '#FDEEF3', '#F0F0FF', '#EAF7EE'];
  static readonly courseTextColors: string[] = ['#2E9B81', '#E07B3A', '#3A6CC7', '#C7517E', '#5B5BC7', '#43995A'];

  // 圆角
  static readonly radiusS: number = 8;
  static readonly radiusM: number = 14;
  static readonly radiusL: number = 20;
}
