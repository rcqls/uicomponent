module uicomponent

import ui
import gx
import os
import x.ttf

[heap]
struct View {
pub mut:
	layout      &ui.CanvasLayout // required
	tf          map[string]ttf.TTF_File
	ttf_render  []ttf.TTF_render_Sokol
	texts       []TextBlock
	text_width  int = 500
	text_height int = 500
	cut_lines   bool
	// To become a component of a parent component
	component voidptr
}

pub struct ViewConfig {
	id          string
	color       gx.Color = ui.no_color
	items       []string
	font_paths  map[string]string
	scrollview  bool
	width       int
	height      int
	full_width  int = -1
	full_height int = -1
	z_index     int
	texts       []TextBlock
	cut_lines   bool = true
}

pub fn view(c ViewConfig) &ui.CanvasLayout {
	mut layout := ui.canvas_plus(
		id: c.id
		bg_color: c.color
		on_draw: view_draw
		scrollview: c.scrollview
		width: c.width
		height: c.height
		full_width: c.full_width
		full_height: c.full_height
		z_index: c.z_index
		full_size_fn: view_full_size
	)
	mut view := &View{
		layout: layout
		texts: c.texts
		cut_lines: c.cut_lines
	}
	view.load_fonts(c.font_paths)
	// add bitmap
	view.bitmap_init()
	view.update_scale()
	// link to one component all the components
	ui.component_connect(view, layout)
	layout.component_type = 'View'
	// init component
	layout.component_init = view_init
	// This needs to be added to the children tree
	return layout
}

fn view_init(c &ui.CanvasLayout) {
	println('view init ($c.x, $c.y)')
	mut v := component_view(c)
	v.update_texts()
}

fn view_draw(c &ui.CanvasLayout, state voidptr) {
	mut v := component_view(c)
	for i, t in v.texts {
		mut txt1 := &(v.ttf_render[i])
		// println("i=$i")
		txt1.bmp.justify = t.justify
		txt1.bmp.align = t.align
		txt1.bmp.color = u32(t.color.rgba8())
		txt1.destroy_texture()
		v.create_text_block(i)
		txt1.create_texture()
		txt1.draw_text_bmp(c.ui.gg, c.x, c.y)
	}
}

fn view_full_size(c &ui.CanvasLayout) (int, int) {
	// println("ici")
	return 500, 500
}

fn (mut v View) load_fonts(fps map[string]string) {
	// load TTF fonts
	for k, fp in fps {
		mut tf := ttf.TTF_File{}
		tf.buf = os.read_bytes(fp) or { panic(err) }
		// println("TrueTypeFont file [$fp] len: ${tf.buf.len}")
		tf.init()
		// println("Unit per EM: $tf.units_per_em")
		v.tf[k] = tf
	}
}

fn (mut v View) bitmap_init() {
	// TODO: ensure that a font exits
	mut fontname := v.tf.keys()[0]
	for mut t in v.texts {
		if t.fontname == '' {
			t.fontname = fontname
		}
		v.ttf_render << &ttf.TTF_render_Sokol{
			bmp: &ttf.BitMap{
				tf: &(v.tf[t.fontname])
			}
		}
	}
}

fn (mut v View) update_scale() {
	for i, mut tf_skl in v.ttf_render {
		scale_reduct := tf_skl.scale_reduct
		device_dpi := tf_skl.device_dpi
		font_size := v.texts[i].fontsize //* scale_reduct
		// Formula: (font_size * device dpi) / (72dpi * em_unit)
		// scale := ((1.0  * devide_dpi )/ f32(72 * tf_skl.bmp.tf.units_per_em))* font_size
		scale := f32(font_size * device_dpi) / f32(72 * tf_skl.bmp.tf.units_per_em)
		// println("Scale: $scale")

		tf_skl.bmp.scale = scale * scale_reduct
		w := v.text_width
		h := v.text_height
		tf_skl.bmp.width = int(w * scale_reduct + 0.5)
		tf_skl.bmp.height = int((h + 2) * scale_reduct + 0.5)
	}
}

// TextBlock

pub struct TextBlock {
mut:
	text []string
	// pos and size
	x         []int
	y         []int
	max_width int
	x_end     int
	y_end     int
	beside    bool
	// style
	fontname string
	fontsize int = 22
	align    ttf.Text_align = .left
	justify  bool
	color    gx.Color = gx.black
}

fn (mut tb TextBlock) join() string {
	return tb.text.join_lines().replace('_CUTLINES_\n', '')
}

fn (mut v View) update_texts() {
	for i, _ in v.texts {
		// println("i=$i")
		v.update_text_block(i)
	}
	// println("texts: ${v.texts}")
}

fn (mut v View) update_text_block(i int) {
	mut bmp := v.ttf_render[i].bmp

	// draw the text

	mut text_block := &(v.texts[i])
	text := text_block.join()
	// println("text = $text")

	unsafe {
		text_block.text.free()
		text_block.x.free()
		text_block.y.free()
	}
	// for i, _ in text_block.text {
	// 	text_block.text.delete_last()
	// }

	mut new_text := []string{}
	mut new_x := []int{}
	mut new_y := []int{}

	mut y_base := int((bmp.tf.y_max - bmp.tf.y_min) * bmp.scale)
	// println('y_base: $y_base (($bmp.tf.y_max - $bmp.tf.y_min) * $bmp.scale)')
	// spaces data
	mut space_cw, _ := bmp.tf.get_horizontal_metrics(u16(` `))
	space_cw = int(space_cw * bmp.scale)

	old_space_cw := bmp.space_cw
	mut end_x, mut end_y := 0, 0

	mut x := 0
	mut y := 0

	if i > 0 {
		x, y = v.texts[i - 1].x_end, v.texts[i - 1].y_end
	}

	mut offset_flag := f32(0) // default .left align
	if bmp.align == .right {
		offset_flag = 1
	} else if bmp.align == .center {
		offset_flag = 0.5
	}

	for txt in text.split_into_lines() {
		bmp.space_cw = old_space_cw
		mut w, _ := bmp.get_bbox(txt)
		// println("${bmp.get_bbox(txt)} $txt")
		if w <= v.text_width || v.cut_lines == false {
			// println("Solid block!")
			left_offset := int((v.text_width - w) * offset_flag)
			// println("left_offset: $left_offset = ($v.text_width - $w) * $offset_flag)")
			if bmp.justify && (f32(w) / f32(v.text_width)) >= bmp.justify_fill_ratio {
				bmp.space_cw = old_space_cw + get_justify_space_cw(txt, w, v.text_width, space_cw)
			}
			// bmp.set_pos(x + left_offset, y + y_base)
			new_x << x + left_offset
			new_y << y + y_base
			new_text << txt
			end_x, _ = bmp.get_bbox(txt)
			end_x += x + left_offset
			// println("$new_x, $new_y, $new_text")
			y += y_base
			end_y = y
		} else {
			// println("to cut: ${txt}")
			mut txt1 := txt.split(' ')
			mut c := txt1.len
			// mut done := false
			for c > 0 {
				tmp_str := txt1[0..c].join(' ')
				// println("tmp_str: ${tmp_str}")
				if tmp_str.len < 1 {
					break
				}

				bmp.space_cw = old_space_cw
				w, _ = bmp.get_bbox(tmp_str)
				if w <= v.text_width {
					mut left_offset := int((v.text_width - w) * offset_flag)
					if bmp.justify && (f32(w) / f32(v.text_width)) >= bmp.justify_fill_ratio {
						// println("cut phase!")
						bmp.space_cw = 0.0
						w, _ = bmp.get_bbox(tmp_str)
						left_offset = int((v.text_width - w) * offset_flag)
						bmp.space_cw = get_justify_space_cw(tmp_str, w, v.text_width,
							space_cw)
					} else {
						bmp.space_cw = old_space_cw
					}

					new_x << x + left_offset
					new_y << y + y_base
					new_text << tmp_str
					end_x, _ = bmp.get_bbox(txt)
					end_x += x + left_offset
					// println("22: $new_x, $new_y, $new_text")
					y += y_base
					end_y = y
					txt1 = txt1[c..]
					c = txt1.len
					//---- DEBUG ----
					// txt2 := txt1.join(' ')
					// println("new string: ${txt2} len: ${c}")
					//---------------
				} else {
					c--
				}
			}
		}
	}
	bmp.space_cw = old_space_cw

	text_block.text = new_text
	text_block.x = new_x
	text_block.y = new_y
	text_block.x_end = 0
	text_block.y_end = end_y
}

fn (mut v View) draw_text(i int) {
	mut bmp := v.ttf_render[i].bmp
	text_block := v.texts[i]
	for k, txt in text_block.text {
		bmp.set_pos(text_block.x[k], text_block.y[k])
		// if k % 2 == 0 {
		// 	bmp.color = u32(gx.red.rgba8())
		// } else {
		// 	bmp.color = u32(gx.yellow.rgba8())
		// }
		// println("k=$k $bmp.color (${text_block.x[k]}, ${text_block.y[k]}): $txt")
		bmp.draw_text(txt)
	}
}

pub fn (mut v View) create_text_block(i int) {
	mut tf_skl := &(v.ttf_render[i])

	sz := tf_skl.bmp.width * tf_skl.bmp.height * tf_skl.bmp.bp

	// if true { return }

	// RAM buffer
	if sz > tf_skl.bmp.buf_size {
		if sz > 0 {
			unsafe { free(tf_skl.bmp.buf) }
		}
		// println('Alloc: $sz bytes')
		tf_skl.bmp.buf = unsafe { malloc_noscan(sz) }
		tf_skl.bmp.buf_size = sz
	}

	tf_skl.bmp.init_filler()

	// draw the text
	mut y_base := int((tf_skl.bmp.tf.y_max - tf_skl.bmp.tf.y_min) * tf_skl.bmp.scale)
	tf_skl.bmp.set_pos(0, y_base)
	tf_skl.bmp.clear()

	v.draw_text(i)
	// v.draw_text_block(i, x: 0, y: 0, w: v.text_width, h: v.text_height)
	tf_skl.format_texture()
}

fn get_justify_space_cw(txt string, w int, block_w int, space_cw int) f32 {
	num_spaces := txt.count(' ')
	if num_spaces < 1 {
		return 0
	}
	delta := block_w - w
	// println("num spc: $num_spaces")
	// println("delta: ${txt} w:$w bw:$block_w space_cw:$space_cw")
	res := f32(delta) / f32(num_spaces) / f32(space_cw)
	// println("res: $res")
	return res
}

/*
pub struct DrawTextBlockConfig {
	x         int  // x postion of the left high corner
	y         int  // y postion of the left high corner
	w 		  int
	h         int
	cut_lines bool = true
}

pub fn (mut v View) draw_text_block(i int, block DrawTextBlockConfig) {
	mut bmp := v.ttf_render[i].bmp
	text := v.texts[i].join()
	mut x := block.x
	mut y := block.y
	mut y_base := int((bmp.tf.y_max - bmp.tf.y_min) * bmp.scale)
	println('y_base: $y_base (($bmp.tf.y_max - $bmp.tf.y_min) * $bmp.scale)')

	bmp.box(x, y, x + block.w, y + block.h, u32(0xFF00_00EE))
	println("($x, $y, ${x + block.w}, ${y + block.h})")
	// spaces data
	mut space_cw, _ := bmp.tf.get_horizontal_metrics(u16(` `))
	space_cw = int(space_cw * bmp.scale)

	old_space_cw := bmp.space_cw

	mut offset_flag := f32(0) // default .left align
	if bmp.align == .right {
		offset_flag = 1
	} else if bmp.align == .center {
		offset_flag = 0.5
	}

	for txt in text.split_into_lines() {
		bmp.space_cw = old_space_cw
		mut w, _ := bmp.get_bbox(txt)
		if w <= block.w || block.cut_lines == false {
			// println("Solid block!")
			left_offset := int((block.w - w) * offset_flag)
			if bmp.justify && (f32(w) / f32(block.w)) >= bmp.justify_fill_ratio {
				bmp.space_cw = old_space_cw + get_justify_space_cw(txt, w, block.w, space_cw)
			}
			bmp.set_pos(x + left_offset, y + y_base)
			// println("${x+left_offset}, ${y + y_base}")
			// bmp.draw_text(txt)
			//---- DEBUG ----
			mut txt_w , _ := bmp.draw_text(txt)
			bmp.box(x + left_offset,y+y_base - int((bmp.tf.y_min)*bmp.scale), x + txt_w + left_offset, y + y_base - int((bmp.tf.y_max) * bmp.scale), u32(0x00ff_ffee) )
			//---------------
			y += y_base
		} else {
			// println("to cut: ${txt}")
			mut txt1 := txt.split(' ')
			mut c := txt1.len
			// mut done := false
			for c > 0 {
				tmp_str := txt1[0..c].join(' ')
				// println("tmp_str: ${tmp_str}")
				if tmp_str.len < 1 {
					break
				}

				bmp.space_cw = old_space_cw
				w, _ = bmp.get_bbox(tmp_str)
				if w <= block.w {
					mut left_offset := int((block.w - w) * offset_flag)
					if bmp.justify && (f32(w) / f32(block.w)) >= bmp.justify_fill_ratio {
						// println("cut phase!")
						bmp.space_cw = 0.0
						w, _ = bmp.get_bbox(tmp_str)
						left_offset = int((block.w - w) * offset_flag)
						bmp.space_cw = get_justify_space_cw(tmp_str, w, block.w, space_cw)
					} else {
						bmp.space_cw = old_space_cw
					}
					bmp.set_pos(x + left_offset, y + y_base)
					println("${x+left_offset}, ${y + y_base}")
					// bmp.draw_text(tmp_str)
					//---- DEBUG ----
					txt_w , _ := bmp.draw_text(tmp_str)
					// println("printing [${x},${y}] => '${tmp_str}' space_cw: $bmp.space_cw")
					bmp.box(x + left_offset,y + y_base - int((bmp.tf.y_min)*bmp.scale), x + txt_w + left_offset, y + y_base - int((bmp.tf.y_max) * bmp.scale), u32(0x0000_00ff) )
					//---------------
					y += y_base
					txt1 = txt1[c..]
					c = txt1.len
					//---- DEBUG ----
					// txt2 := txt1.join(' ')
					// println("new string: ${txt2} len: ${c}")
					//---------------
				} else {
					c--
				}
			}
		}
	}

	bmp.space_cw = old_space_cw
}
*/
