import ui
import uicomponent as uic
import gx

const (
	win_width  = 600
	win_height = 400
)

struct App {
mut:
	window &ui.Window
}

fn main() {
	mut app := &App{
		window: 0
	}
	cb_layout := uic.colorbox(id: 'cbox', light: false, hsl: false)
	rect := ui.rectangle(
		text: 'Here a simple ui rectangle '
		text_cfg: gx.TextCfg{
			color: gx.blue
			align: gx.align_left
			size: 30
		}
	)
	window := ui.window(
		width: win_width
		height: win_height
		title: 'V UI: Toolbar'
		state: app
		mode: .resizable
		native_message: false
		children: [
			ui.column(
				margin_: .05
				spacing: .05
				children: [
					uic.tabs(
						id: 'tab'
						tabs: ['tab1', 'tab2', 'tab3']
						pages: [
							ui.column(
							heights: ui.compact
							widths: ui.compact
							bg_color: gx.rgb(200, 100, 200)
							children: [
								ui.button(id: 'left1', text: 'toto', padding: .1, radius: .25),
								ui.button(id: 'left2', text: 'toto2'),
							]
						),
							ui.column(
								heights: ui.compact
								widths: ui.compact
								children: [
									cb_layout,
									rect,
								]
							),
							ui.column(
								heights: 200.0
								widths: 300.0
								bg_color: gx.rgb(100, 200, 200)
								children: [
									uic.doublelistbox(
										id: 'dlb1'
										title: 'dlb1'
										items: [
											'totto',
											'titi',
										]
									),
								]
							),
						]
					),
				]
			),
		]
	)
	mut cb := uic.component_colorbox(cb_layout)
	cb.connect(&rect.color)
	app.window = window
	ui.run(window)
}
