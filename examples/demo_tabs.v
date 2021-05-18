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
	window := ui.window({
		width: win_width
		height: win_height
		title: 'V UI: Toolbar'
		state: app
		mode: .resizable
		native_message: false
	}, [
		ui.column({
			margin_: .05
			spacing: .05
		}, [
			uic.tabs(
				id: 'tab'
				tabs: ['tab1', 'tab2', 'tab3']
				pages: [
					ui.column({
					heights: ui.compact
					widths: ui.compact
					bg_color: gx.rgb(200, 100, 200)
				}, [
					ui.button(id: 'left1', text: 'toto', padding: .1, radius: .25),
					ui.button(id: 'left2', text: 'toto2'),
				]),
					ui.column({
						heights: ui.compact
						widths: ui.compact
						bg_color: gx.rgb(100, 200, 200)
					}, [
						// ui.button(id: 'left3', text: 'toto3', padding: .1, radius: .25),
						// ui.button(id: 'left4', text: 'toto4')
						uic.colorbox(id: 'cbox', light: false, hsl: false),
					]),
					ui.column({
						heights: 200.
						widths: 300.
						bg_color: gx.rgb(100, 200, 200)
					}, [
						uic.doublelistbox(id: 'dlb1', title: 'dlb1', items: ['totto', 'titi']),
					]),
				]
			),
		]),
	])
	app.window = window
	ui.run(window)
}
