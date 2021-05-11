module uicomponent

import ui

[heap]
struct DoubleListBox {
pub mut:
	layout    &ui.Stack // optional
	lb_left   &ui.ListBox
	lb_right  &ui.ListBox
	btn_left  &ui.Button
	btn_right &ui.Button
	btn_clear &ui.Button
	// To become a component of a parent component
	component voidptr
}

pub struct DoubleListBoxConfig {
	id    string
	title string
	items []string
}

pub fn doublelistbox(c DoubleListBoxConfig) &ui.Stack {
	//
	mut items := map[string]string{}
	for item in c.items {
		items[item] = item
	}
	mut lb_left := ui.listbox({ width: 50 }, items)
	mut lb_right := ui.listbox({ width: 50 }, map[string]string{})
	mut btn_right := ui.button(text: '>>', onclick: doublelistbox_move_right)
	mut btn_left := ui.button(text: '<<', onclick: doublelistbox_move_left)
	mut btn_clear := ui.button(text: 'clear', onclick: doublelistbox_clear)
	mut layout := ui.row({
		title: c.title
		id: c.id
		widths: [4 * ui.stretch, 2 * ui.stretch, 4 * ui.stretch]
		heights: ui.stretch
		spacing: .05
	}, [
		lb_left,
		ui.column({ widths: ui.stretch, heights: ui.compact, spacing: 10 }, [btn_right, btn_left,
			btn_clear,
		]),
		lb_right,
	])
	dbl_lb := &DoubleListBox{
		layout: layout
		lb_left: lb_left
		lb_right: lb_right
		btn_left: btn_left
		btn_right: btn_right
		btn_clear: btn_clear
	}
	// attach to one component all the components
	lb_left.component = dbl_lb
	lb_right.component = dbl_lb
	btn_left.component = dbl_lb
	btn_right.component = dbl_lb
	btn_clear.component = dbl_lb

	layout.component = dbl_lb

	layout.component_type = 'DoubleListBox'
	// This needs to be added to the children tree
	return layout
}

// callback
fn doublelistbox_clear(a voidptr, btn &ui.Button) {
	mut dlb := component_doublelistbox(btn)
	for item in dlb.lb_right.values() {
		dlb.lb_left.add_item(item, item)
		dlb.lb_right.remove_item(item)
	}
}

fn doublelistbox_move_left(a voidptr, btn &ui.Button) {
	mut dlb := component_doublelistbox(btn)
	if dlb.lb_right.is_selected() {
		_, item := dlb.lb_right.selected() or { '', '' }
		println('move << $item')
		if !(item in dlb.lb_left.values()) {
			dlb.lb_left.add_item(item, item)
			dlb.lb_right.remove_item(item)
		}
	}
}

fn doublelistbox_move_right(a voidptr, btn &ui.Button) {
	mut dlb := component_doublelistbox(btn)
	if dlb.lb_left.is_selected() {
		_, item := dlb.lb_left.selected() or { '', '' }
		// println("move >> $item")
		if !(item in dlb.lb_right.values()) {
			dlb.lb_right.add_item(item, item)
			dlb.lb_left.remove_item(item)
		}
	}
}

pub fn (dlb &DoubleListBox) values() []string {
	return dlb.lb_right.values()
}

// No need from now
// fn doublelistbox_change(app voidptr, lb &ListBox) {
// 	// println("selected: $lb.selection")
// }
