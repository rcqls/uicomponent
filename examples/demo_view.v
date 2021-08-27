import ui
import gx
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
		title: 'V UI: View'
		state: app
		mode: .resizable
		native_message: false
		children: [
			ui.row(
				widths: ui.stretch
				children: [
					// ui.rectangle({color: gx.white})
					uic.view(
						id: 'view'
						color: gx.white
						font_paths: {
							'imprima':  'assets/Imprima-Regular.ttf'
							'graduate': 'assets/Graduate-Regular.ttf'
						}
						scrollview: true
						texts: [
							uic.TextBlock{
								text: ["Today it is a good day!
Tommorow I'm not so sure :(
But Vwill prevail for sure, V is the way!!
"]
								color: gx.blue
								fontsize: 14
							},
							uic.TextBlock{
								text: ["Todayyy it is a good day!
Tommorow I'm not so sure :("]
								color: gx.red
								fontname: 'graduate'
							},
						]
					),
					uic.view(
						id: 'view'
						// width: 300
						// height: 300
						full_width: 800
						full_height: 500
						// color: gx.white
						font_paths: {
							'imprima':  'assets/Imprima-Regular.ttf'
							'graduate': 'assets/Graduate-Regular.ttf'
						}
						scrollview: true
						texts: [
							uic.TextBlock{
								text: ["Today it is a good day!
Tommorow I'm not so sure :(
But Vwill prevail for sure, V is the way!!
"]
								color: gx.blue
								fontsize: 32
							},
							uic.TextBlock{
								text: ["Todayyy it is a good day!
Tommorow I'm not so sure :("]
								color: gx.red
								fontname: 'graduate'
							},
						]
					),
				]
			),
		]
	)
	app.window = window
	ui.run(window)
}
