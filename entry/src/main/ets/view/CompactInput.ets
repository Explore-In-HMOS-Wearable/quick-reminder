import { ReminderViewModel } from '../viewmodel/ReminderViewModel';

@Component
export struct CompactInput {
  placeholder: ResourceStr = '';
  inputType: InputType = InputType.Normal;
  @ObjectLink vm: ReminderViewModel;
  type: 'title' | 'content' | 'time' = 'title';

  build() {
    TextInput({
      placeholder: this.placeholder,
      text: this.type === 'title' ? this.vm.title : (this.type === 'content' ? this.vm.content : this.vm.timeInput)
    })
      .width('100%')
      .height($r('app.float.input_height'))
      .fontSize($r('app.float.font_input'))
      .placeholderFont({ size: $r('app.float.font_input') })
      .placeholderColor($r('app.color.input_placeholder'))
      .fontColor(Color.White)
      .backgroundColor($r('app.color.input_bg'))
      .borderRadius($r('app.float.input_radius'))
      .padding({ left: $r('app.float.input_padding_side'), right: $r('app.float.input_padding_side') })
      .type(this.inputType)
      .onChange((val: string) => {
        if (this.type === 'title') {
          this.vm.title = val;
        }
        if (this.type === 'content') {
          this.vm.content = val;
        }
        if (this.type === 'time') {
          this.vm.timeInput = val;
        }
      })
  }
}