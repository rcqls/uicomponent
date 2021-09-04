module uicomponent

import ui
import os

const (
	fontchooser_row_id = '_row_sw_font'
	fontchooser_lb_id  = '_lb_sw_font'
)

[heap]
struct FontChooser {
pub mut:
	layout &ui.Stack // required
	dtw    ui.DrawTextWidget
	// To become a component of a parent component
	component voidptr
}

pub struct FontChooserConfig {
	id         string = uicomponent.fontchooser_lb_id
	draw_lines bool   = true
	dtw        ui.DrawTextWidget = ui.canvas_plus() // since it requires an intialisation
}

pub fn fontchooser(c FontChooserConfig) &ui.Stack {
	mut lb := ui.listbox(
		id: c.id
		scrollview: true
		draw_lines: c.draw_lines
		on_change: fontchooser_lb_change
	)
	fontchooser_add_fonts_items(mut lb)
	layout := ui.row(
		id: uicomponent.fontchooser_row_id
		widths: 300.0
		heights: 200.0
		children: [lb]
	)
	mut fc := &FontChooser{
		layout: layout
		dtw: c.dtw
	}
	ui.component_connect(fc, layout, lb)
	return layout
}

pub fn component_fontchooser(w ui.ComponentChild) &FontChooser {
	return &FontChooser(w.component)
}

fn fontchooser_add_fonts_items(mut lb ui.ListBox) {
	mut font_root_path := ''
	$if windows {
		font_root_path = 'C:/windows/fonts'
	}
	$if macos {
		font_root_path = '/System/Library/Fonts/*'
	}
	$if linux {
		font_root_path = '/usr/share/fonts/truetype/*'
	}
	font_paths := os.glob('$font_root_path/*.ttf') or { panic(err) }

	for fp in font_paths {
		lb.append_item(fp, os.file_name(fp), 0)
	}
}

pub fn fontchooser_connect(w &ui.Window, dtw ui.DrawTextWidget) {
	fc_layout := w.stack(uicomponent.fontchooser_row_id)
	mut fc := component_fontchooser(fc_layout)
	fc.dtw = dtw
}

fn fontchooser_lb_change(a voidptr, lb &ui.ListBox) {
	mut w := lb.ui.window
	fc := component_fontchooser(lb)
	// println('fc_lb_change: $lb.id')
	mut dtw := ui.DrawTextWidget(fc.dtw)
	fp, id := lb.selected() or { 'classic', '' }
	// println("$id, $fp")
	$if windows {
		w.ui.add_font(id, 'C:/windows/fonts/$fp')
	} $else {
		w.ui.add_font(id, fp)
	}

	dtw.update_text_style(font_name: id)
}
