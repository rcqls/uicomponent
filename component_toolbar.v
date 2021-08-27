module uicomponent

import ui

[heap]
struct ToolBar {
pub mut:
	layout &ui.Stack // required
	items  []ui.Widget
	// To become a component of a parent component
	component voidptr
}

pub struct ToolBarConfig {
	id       string
	widths   ui.Size
	heights  ui.Size
	spacing  f64 // Size = Size(0.) // Spacing = Spacing(0) // int
	spacings []f64 = []f64{}
	items    []ui.Widget
}

pub fn toolbar(c ToolBarConfig) &ui.Stack {
	mut layout := ui.row(
		id: c.id
		widths: c.widths
		heights: c.heights
		spacing: c.spacing
		spacings: c.spacings
		children: c.items
	)
	tb := &ToolBar{
		layout: layout
		items: c.items
	}
	for mut child in c.items {
		if mut child is ui.Button {
			child.component = tb
		} else if mut child is ui.Label {
			child.component = tb
		} else if mut child is ui.Rectangle {
			child.component = tb
		}
	}
	return layout
}
