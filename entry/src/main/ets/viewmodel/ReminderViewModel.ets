import { ReminderService } from '../common/utils/ReminderService';
import { common } from '@kit.AbilityKit';

@Observed
export class ReminderViewModel {
  public title: string = '';
  public content: string = '';
  public timeInput: string = '';
  public statusMessage: string = '';
  public currentReminderId: number = -1;
  public isFormVisible: boolean = false;

  private notificationCounter: number = 1000;
  private service = ReminderService.getInstance();

  async authorize(context: common.UIAbilityContext) {
    await this.service.requestNotificationPermission(context);
  }

  async saveReminder() {
    const seconds = parseInt(this.timeInput);

    if (isNaN(seconds) || seconds <= 0 || !this.title || !this.content) {
      this.statusMessage = 'Please fill all fields correctly.';
      return;
    }

    try {
      this.notificationCounter++;
      const id = await this.service.addTimerReminder(
        this.title,
        this.content,
        seconds,
        this.notificationCounter
      );
      this.currentReminderId = id;
      this.statusMessage = 'Reminder successfully scheduled!';
      this.resetForm();
    } catch (err) {
      this.statusMessage = `Error: ${(err as Error).message}`;
    }
  }

  async loadReminders() {
    try {
      const activeList = await this.service.getAllActiveReminders();
      this.statusMessage = activeList.length > 0
        ? `Active Reminders: ${activeList.length}`
        : 'No active reminders found.';
    } catch (err) {
      this.statusMessage = 'Failed to fetch reminders.';
    }
  }

  async deleteReminder() {
    if (this.currentReminderId === -1) {
      this.statusMessage = 'No reminder to cancel.';
      return;
    }
    try {
      await this.service.cancelReminder(this.currentReminderId);
      this.currentReminderId = -1;
      this.statusMessage = 'Reminder cancelled.';
    } catch (err) {
      this.statusMessage = 'Cancellation failed.';
    }
  }

  private resetForm() {
    this.isFormVisible = false;
    this.title = '';
    this.content = '';
    this.timeInput = '';
  }
}