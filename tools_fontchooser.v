module uicomponent

import ui

const (
	fontchooser_id = '_sw_font'
)

// Append fontchooser to window
pub fn fontchooser_add(mut w ui.Window, fontchooser_lb_change ui.ListBoxSelectionChangedFn) {
	// only once
	if !ui.Layout(w).has_child_id(uicomponent.fontchooser_id) {
		w.children << ui.subwindow(
			id: uicomponent.fontchooser_id
			z_index: 1000
			layout: fontchooser()
		)
	}
}

pub fn fontchooser_visible(w &ui.Window) {
	mut s := w.subwindow(uicomponent.fontchooser_id)
	s.set_visible(s.hidden)
	s.update_layout()
}

pub fn fontchooser_subwindow(w &ui.Window) &ui.SubWindow {
	return w.subwindow(uicomponent.fontchooser_id)
}

pub fn fontchooser_listbox(w &ui.Window) &ui.ListBox {
	return w.listbox(fontchooser_lb_id)
}

fn btn_font_click(a voidptr, b &ui.Button) {
	fontchooser_visible(b.ui.window)
}

/*
fn lb_change(mut app App, lb &ui.ListBox) {
	mut w := lb.ui.window
	c := w.canvas_layout('c')
	mut dtw := ui.DrawTextWidget(c)
	fp, id := lb.selected() or { 'classic', '' }
	// println("$id, $fp")
	$if windows {
		w.ui.add_font(id, 'C:/windows/fonts/$fp')
	} $else {
		w.ui.add_font(id, fp)
	}

	app.prev_font = id
	dtw.update_text_style(font_name: id, size: 30)
}
*/

/*
ui.button(
	id: 'btn_font'
	text: "font"
	onclick: btn_font_click
)


pub struct ButtonFontConfig {
	id           string
	dtw_id 		 string
	text         string
	height       int
	width        int
	z_index      int
	tooltip      string
	tooltip_side ui.Side = .top
	radius       f64
	padding      f64
	bg_color 	 &gx.Color
}

pub fn button_font(c ButtonFontConfig) &ui.Button {
	b := &ui.Button{
		id: "$c.id_&_$c.dtw_id"
		width_: c.width
		height_: c.height
		z_index: c.z_index
		bg_color: c.bg_color
		theme_cfg: ui.no_theme
		tooltip: ui.TooltipMessage{c.tooltip, c.tooltip_side}
		onclick: button_font_click
		radius: f32(c.radius)
		padding: f32(c.padding)
		ui: 0
	}
	return b
}

fn button_font_click(a voidptr, b &ui.Button) {
	_, = b.id.split("_&_")
	fontchooser_connect(b.ui.window)
}
*/
