import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { notificationManager } from '@kit.NotificationKit';
import { common } from '@kit.AbilityKit';
import Logger from './Logger';
import { vibrator } from '@kit.SensorServiceKit';

export class ReminderService {
  private static instance: ReminderService;

  private constructor() {}

  public static getInstance(): ReminderService {
    if (!ReminderService.instance) {
      ReminderService.instance = new ReminderService();
    }
    return ReminderService.instance;
  }

  async requestNotificationPermission(context: common.UIAbilityContext): Promise<void> {
    try {
      await notificationManager.requestEnableNotification(context);
      Logger.info('Permission request successful');
    } catch (err) {
      Logger.error(`Permission request failed: ${JSON.stringify(err)}`);
    }
  }

  async addTimerReminder(title: string, content: string, seconds: number, id: number): Promise<number> {
    const timer: reminderAgentManager.ReminderRequestTimer = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
      triggerTimeInSeconds: seconds,
      title: title,
      content: content,
      notificationId: id,
      slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
      ringDuration: 5
    };

    this.playSimpleVibration();

    return await reminderAgentManager.publishReminder(timer);
  }

  private playSimpleVibration() {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 100
      }, {
        id: 0,
        usage: 'alarm'
      });
    } catch (err) {
      console.error('Vibration failed');
    }
  }

  async cancelReminder(reminderId: number): Promise<void> {
    return await reminderAgentManager.cancelReminder(reminderId);
  }

  async getAllActiveReminders(): Promise<reminderAgentManager.ReminderRequest[]> {
    return await reminderAgentManager.getValidReminders();
  }
}