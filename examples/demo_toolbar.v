import ui
import uicomponent as uic

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
					uic.toolbar(
						widths: [.1, .1, 2 * ui.stretch, .1, ui.stretch, .1]
						heights: .1
						items: [ui.button(id: 'left1', text: 'toto', padding: .1, radius: .25),
							ui.button(id: 'left2', text: 'toto2'),
							ui.spacing(), ui.button(id: 'btn2', text: 'tata'),
							ui.spacing(), ui.button(id: 'btn3', text: 'tati')]
					),
				]
			),
		]
	)
	app.window = window
	ui.run(window)
}
