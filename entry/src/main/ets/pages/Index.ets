import { common } from '@kit.AbilityKit';
import { ReminderViewModel } from '../viewmodel/ReminderViewModel';
import { MenuButton } from '../view/MenuButton';
import { CompactInput } from '../view/CompactInput';

@Entry
@Component
struct Index {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State vm: ReminderViewModel = new ReminderViewModel();

  aboutToAppear() {
    this.vm.authorize(this.context);
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [[$r('app.color.bg_gradient_start'), 0.0], [$r('app.color.bg_gradient_end'), 1.0]]
        })

      Scroll() {
        Column({ space: 8 }) {
          Text($r('app.string.label_quick_reminder'))
            .fontSize($r('app.float.font_small'))
            .fontColor($r('app.color.primary_cyan'))
            .fontWeight(FontWeight.Bolder)
            .margin({ top: $r('app.float.spacing_large'), bottom: 5 })
            .textShadow({
              radius: 4,
              color: $r('app.color.shadow_cyan'),
              offsetX: 0,
              offsetY: 0
            })

          if (this.vm.isFormVisible) {
            this.ReminderFormView()
          } else {
            this.ActionButtonsView()
          }

          if (this.vm.statusMessage) {
            Text(this.vm.statusMessage)
              .fontSize($r('app.float.font_tiny'))
              .fontColor($r('app.color.primary_cyan'))
              .textAlign(TextAlign.Center)
              .width('80%')
              .margin({ top: 5, bottom: $r('app.float.spacing_large') })
          }
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ActionButtonsView() {
    Column({ space: 6 }) {
      MenuButton({
        label: $r('app.string.label_new_task'),
        color: $r('app.color.primary_cyan'),
        action: () => this.vm.isFormVisible = true
      })
      MenuButton({
        label: $r('app.string.label_list'),
        color: $r('app.color.primary_green'),
        action: () => {
          this.vm.loadReminders()
        }
      })
      MenuButton({
        label: $r('app.string.label_cancel'),
        color: $r('app.color.primary_red'),
        action: () => {
          this.vm.deleteReminder()
        }
      })
    }
    .width('75%')
  }

  @Builder
  ReminderFormView() {
    Column({ space: 5 }) {
      CompactInput({
        placeholder: $r('app.string.placeholder_name'),
        vm: this.vm,
        type: 'title'
      })
      CompactInput({
        placeholder: $r('app.string.placeholder_desc'),
        vm: this.vm,
        type: 'content'
      })
      CompactInput({
        placeholder: $r('app.string.placeholder_secs'),
        vm: this.vm,
        type: 'time',
        inputType: InputType.Number
      })

      Row({ space: $r('app.float.spacing_small') }) {
        Button($r('app.string.label_set'))
          .height($r('app.float.btn_height'))
          .width('50%')
          .fontSize($r('app.float.font_tiny'))
          .fontWeight(FontWeight.Bold)
          .backgroundColor($r('app.color.primary_cyan'))
          .onClick(() => this.vm.saveReminder())

        Button($r('app.string.label_cancel'))
          .width('50%')
          .height($r('app.float.btn_height'))
          .fontColor(Color.White)
          .fontSize($r('app.float.font_tiny'))
          .fontWeight(FontWeight.Bold)
          .backgroundColor($r('app.color.button_secondary'))
          .onClick(() => this.vm.isFormVisible = false)
      }
      .width('100%')
      .margin({ top: $r('app.float.spacing_tiny') })
    }
    .padding($r('app.float.spacing_medium'))
    .backgroundColor($r('app.color.form_bg'))
    .borderRadius($r('app.float.border_radius_m'))
    .width('70%')
    .border({ width: $r('app.float.border_thin'), color: $r('app.color.form_border') })
  }
}