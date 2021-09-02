module uicomponent

import ui
import gx

[heap]
struct FontButton {
pub mut:
	btn &ui.Button
	dtw ui.DrawTextWidget
}

pub struct FontButtonConfig {
	id           string
	dtw          ui.DrawTextWidget = ui.canvas_plus()
	text         string
	height       int
	width        int
	z_index      int
	tooltip      string
	tooltip_side ui.Side = .top
	radius       f64
	padding      f64
	bg_color     &gx.Color = 0
}

pub fn fontbutton(c FontButtonConfig) &ui.Button {
	b := &ui.Button{
		id: c.id
		text: c.text
		width_: c.width
		height_: c.height
		z_index: c.z_index
		bg_color: c.bg_color
		theme_cfg: ui.no_theme
		tooltip: ui.TooltipMessage{c.tooltip, c.tooltip_side}
		onclick: fontbutton_click
		radius: f32(c.radius)
		padding: f32(c.padding)
		ui: 0
	}
	mut fb := &FontButton{
		btn: b
		dtw: c.dtw
	}
	ui.component_connect(fb, b)
	return b
}

pub fn component_fontbutton(w ui.ComponentChild) &FontButton {
	return &FontButton(w.component)
}

fn fontbutton_click(a voidptr, b &ui.Button) {
	fb := component_fontbutton(b)
	println('fb_click $fb.dtw.id')
	fontchooser_connect(b.ui.window, fb.dtw)
	fontchooser_visible(b.ui.window)
}
