@Component
export struct MenuButton {
  label: ResourceStr = '';
  color: ResourceColor = $r('app.color.primary_cyan');
  action: () => void = () => {
  };

  build() {
    Button(this.label)
      .width('100%')
      .height($r('app.float.menu_btn_height'))
      .fontSize($r('app.float.menu_btn_font_size'))
      .fontWeight(FontWeight.Bold)
      .fontColor(Color.White)
      .backgroundColor($r('app.color.button_bg_glass'))
      .border({
        width: $r('app.float.menu_btn_border_width'),
        color: this.color
      })
      .borderRadius($r('app.float.menu_btn_radius'))
      .onClick(() => this.action())
  }
}