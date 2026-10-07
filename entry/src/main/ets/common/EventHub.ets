/**
 * 简易事件总线，用于跨页面数据实时同步
 * 任意页面修改数据后通知所有订阅者重新加载，保证数据一致性
 */
export type DataChangeCallback = () => void;

export class EventHub {
  private static instance: EventHub | null = null;
  private listeners: Map<number, DataChangeCallback> = new Map();
  private nextId: number = 1;

  static getInstance(): EventHub {
    if (EventHub.instance === null) {
      EventHub.instance = new EventHub();
    }
    return EventHub.instance;
  }

  // 订阅数据变更，返回订阅id用于取消
  subscribe(cb: DataChangeCallback): number {
    const id: number = this.nextId;
    this.nextId = this.nextId + 1;
    this.listeners.set(id, cb);
    return id;
  }

  unsubscribe(id: number): void {
    this.listeners.delete(id);
  }

  // 通知所有订阅者
  emit(): void {
    this.listeners.forEach((cb: DataChangeCallback) => {
      cb();
    });
  }
}
