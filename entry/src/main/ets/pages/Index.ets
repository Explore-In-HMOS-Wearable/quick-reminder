import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../common/utils/Logger';
import { notificationManager } from '@kit.NotificationKit';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private reminderId: number = -1;
  @State reminderStatus: string = ''; // Stores status messages for UI feedback
  @State reminderTitle: string = ''; // Reminder title input
  @State reminderContent: string = ''; // Reminder content input
  @State reminderTime: string = ''; // Reminder time input (in seconds)
  @State showInputForm: boolean = false; // Flag to toggle the reminder form
  @State notificationId: number = 1000; // Notification ID counter

  aboutToAppear() {
    // Request notification permission when component appears
    this.openNotificationPermission(this.context);
  }

  build() {
    Scroll() {
      Column() {
        // Title text
        Text($r('app.string.title_text'))
          .fontSize($r('app.float.title_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.title_text'))
          .textAlign(TextAlign.Center)
          .margin({ bottom: $r('app.float.title_margin_bottom') })

        if (this.showInputForm) {
          // Show input form if toggled on
          Column() {
            this.addForm()
          }
          .borderRadius($r('app.float.border_radius_large'))
          .backgroundColor(Color.White)
          .width('70%')
        } else {
          // Button: Create Reminder
          Row({ space: $r('app.float.row_space') }) {
            Image($r('app.media.bolt')).width('15%')

            Text($r('app.string.create_reminder'))
              .fontSize($r('app.float.page_text_font_size'))
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .textAlign(TextAlign.Center)
          }
          .width('60%')
          .height($r('app.float.medium_height'))
          .borderRadius($r('app.float.border_radius_medium'))
          .backgroundColor($r('app.color.button_create_background'))
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.showInputForm = true;
            this.createReminder();
          })

          // Button: Show Reminders
          Row({ space: $r('app.float.row_space') }) {
            Image($r('app.media.cat')).width('15%')

            Text($r('app.string.show_reminders'))
              .fontSize($r('app.float.page_text_font_size'))
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .textAlign(TextAlign.Center)
          }
          .backgroundColor(($r('app.color.button_show_background')))
          .width('60%')
          .height($r('app.float.medium_height'))
          .borderRadius($r('app.float.border_radius_medium'))
          .margin({ top: $r('app.float.button_show_margin_top') })
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.listReminders();
          })

          // Button: Cancel Reminder
          Row({ space: $r('app.float.row_space') }) {
            Image($r('app.media.bomb')).width('15%')

            Text($r('app.string.cancel_reminder'))
              .fontSize($r('app.float.page_text_font_size'))
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .textAlign(TextAlign.Center)
          }
          .backgroundColor(($r('app.color.button_cancel_background')))
          .width('60%')
          .height($r('app.float.medium_height'))
          .borderRadius($r('app.float.border_radius_medium'))
          .margin({ top: $r('app.float.button_cancel_margin_top') })
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.cancelReminder();
          })

          // Show reminder status message if available
          if (this.reminderStatus !== '') {
            Text(this.reminderStatus)
              .fontSize($r('app.float.page_text_font_size'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.button_show_background'))
              .margin({ top: $r('app.float.status_text_margin_top') })
          }
        }
      }
      .padding(20)
      .alignItems(HorizontalAlign.Center)
    }
    .height('100%')
    .width('100%')
    .backgroundColor(($r('app.color.main_background')))
  }

  private openNotificationPermission(context: common.UIAbilityContext) {
    // Request notification permission from the user
    notificationManager.requestEnableNotification(context).then(() => {
      Logger.info('Enable notification success');
    }).catch((err: Error) => {
      Logger.error('Enable notification failed because ' + JSON.stringify(err));
    });
  }

  private createReminder() {
    Logger.info('createReminder() started');

    const timeInSeconds = parseInt(this.reminderTime);

    // Validate reminder time
    if (isNaN(timeInSeconds) || timeInSeconds <= 0) {
      Logger.info('Invalid time input');
      this.reminderStatus = JSON.stringify($r('app.string.title_text'));
      return;
    }

    // Validate inputs
    if (!this.reminderTitle || !this.reminderContent) {
      Logger.info('Title or content missing');
      this.reminderStatus = JSON.stringify($r('app.string.status_missing_fields'));
      return;
    }

    // Create reminder request object
    let timerReminder: reminderAgentManager.ReminderRequestTimer = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
      triggerTimeInSeconds: timeInSeconds,
      title: this.reminderTitle,
      content: this.reminderContent,
      notificationId: ++this.notificationId
    };

    Logger.info(`Publishing reminder with ID: ${this.notificationId}`);

    // Publish reminder
    reminderAgentManager.publishReminder(timerReminder).then((id: number) => {
      Logger.info(`Reminder published successfully with request ID: ${id}`);
      this.reminderId = id;
      this.reminderStatus = JSON.stringify($r('app.string.status_set'));
      this.showInputForm = false;
      this.reminderTitle = '';
      this.reminderContent = '';
      this.reminderTime = '';
    }).catch((err: BusinessError) => {
      Logger.info(`Failed to publish reminder: ${err.code}, ${err.message}`);
      this.reminderStatus = `Error: ${err.code}, ${err.message}`;
    });
  }

  private listReminders() {
    Logger.info('listReminders() started');

    // Get active reminders
    reminderAgentManager.getValidReminders().then((reminders) => {
      Logger.info(`Retrieved ${reminders.length} active reminders`);
      if (reminders.length === 0) {
        this.reminderStatus = JSON.stringify($r('app.string.status_no_reminders'));
        return;
      }

      this.reminderStatus = `Total reminders: ${reminders.length}`;
    }).catch((err: BusinessError) => {
      Logger.info(`Error while listing reminders: ${err.code}`);
      this.reminderStatus = `Listing error: ${err.code}`;
    });
  }

  private cancelReminder() {
    Logger.info('cancelReminder() started');

    // Check if reminder exists
    if (this.reminderId === -1) {
      Logger.info('No reminder to cancel');
      this.reminderStatus = JSON.stringify($r('app.string.status_need_reminder'));
      return;
    }

    // Cancel reminder
    reminderAgentManager.cancelReminder(this.reminderId).then(() => {
      Logger.info(`Reminder ${this.reminderTitle} canceled successfully`);
      this.reminderStatus = JSON.stringify($r('app.string.status_canceled'));
      this.reminderId = -1;
    }).catch((err: BusinessError) => {
      Logger.info(`Failed to cancel reminder: ${err.code}`);
      this.reminderStatus = `Cancellation error: ${err.code}`;
    });
  }

  @Builder
  addForm() {
    // Input: Title
    TextInput({ placeholder: $r('app.string.input_title_placeholder') })
      .onChange((val: string) => this.reminderTitle = val)
      .width('80%')
      .borderRadius($r('app.float.border_radius_small'))
      .backgroundColor($r('app.color.input_title_background'))
      .fontColor(Color.White)
      .placeholderColor(Color.White)
      .fontSize($r('app.float.small_text_font_size'))
      .placeholderFont({ size: $r('app.float.placeholder_font_size') })
      .margin({ bottom: $r('app.float.input_title_margin_bottom'), top: $r('app.float.input_title_margin_top') })
      .height($r('app.float.small_height'))

    // Input: Content
    TextInput({ placeholder: $r('app.string.input_content_placeholder') })
      .onChange((val: string) => this.reminderContent = val)
      .width('80%')
      .borderRadius($r('app.float.border_radius_small'))
      .backgroundColor($r('app.color.input_content_background'))
      .fontColor(Color.White)
      .placeholderColor(Color.White)
      .fontSize($r('app.float.small_text_font_size'))
      .placeholderFont({ size: $r('app.float.placeholder_font_size') })
      .margin({ bottom: $r('app.float.input_content_margin_bottom') })
      .height($r('app.float.small_height'))

    // Input: Time (in seconds)
    TextInput({ placeholder: $r('app.string.input_time_placeholder') })
      .onChange((val: string) => this.reminderTime = val)
      .width('80%')
      .height($r('app.float.small_height'))
      .borderRadius($r('app.float.border_radius_small'))
      .backgroundColor($r('app.color.input_time_background'))
      .fontColor(Color.White)
      .placeholderColor(Color.White)
      .fontSize($r('app.float.small_text_font_size'))
      .placeholderFont({ size: $r('app.float.placeholder_font_size') })


    // Button: Save Reminder
    Row({ space: $r('app.float.row_space') }) {
      Image($r('app.media.star')).width('20%')

      Text($r('app.string.save_button'))
        .fontSize($r('app.float.save_button_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
    }
    .backgroundColor($r('app.color.button_save_background'))
    .width('40%')
    .height($r('app.float.small_height'))
    .borderRadius($r('app.float.border_radius_small'))
    .margin({ top: $r('app.float.button_save_margin_top'), bottom: $r('app.float.button_save_margin_bottom') })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.createReminder();
    })
  }
}
