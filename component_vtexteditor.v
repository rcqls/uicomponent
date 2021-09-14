module uicomponent

import ui

struct VTextEdit {
pub mut:
	layout &ui.Stack
	tb     &ui.TextBox
	sh     &SyntaxHighlight
}

struct SyntaxHighlight {
pub mut:
	keys          []string
	chunks        []Chunk
	is_ml_comment bool
}

pub fn vtextedit() &ui.Stack {
	return ui.row()
}

// BORROWED mostly from vte
// For syntax highlighting
enum ChunkKind {
	a_string = 1
	a_comment = 2
	a_key = 3
}

struct Chunk {
	start int
	end   int
	typ   ChunkKind
}

fn (mut sh SyntaxHighlight) add_chunk(typ ChunkKind, start int, end int) {
	chunk := Chunk{
		typ: typ
		start: start
		end: end
	}
	sh.chunks << chunk
}

fn (mut sh SyntaxHighlight) line_chunks(line string) {
	sh.chunks = []
	for i := 0; i < line.len; i++ {
		start := i
		// Comment // #
		if i > 0 && line[i - 1] == `/` && line[i] == `/` {
			sh.add_chunk(.a_comment, start - 1, line.len)
			break
		}
		if line[i] == `#` {
			sh.add_chunk(.a_comment, start, line.len)
			break
		}
		// Comment   /*
		// (unless it's /* line */ which is a single line)
		if i > 0 && line[i - 1] == `/` && line[i] == `*` && !(line[line.len - 2] == `*`
			&& line[line.len - 1] == `/`) {
			// All after /* is  a comment
			sh.add_chunk(.a_comment, start, line.len)
			sh.is_ml_comment = true
			break
		}
		// End of /**/
		if i > 0 && line[i - 1] == `*` && line[i] == `/` {
			// All before */ is still a comment
			sh.add_chunk(.a_comment, 0, start + 1)
			sh.is_ml_comment = false
			break
		}
		// String
		if line[i] == `'` {
			i++
			for i < line.len - 1 && line[i] != `'` {
				i++
			}
			if i >= line.len {
				i = line.len - 1
			}
			sh.add_chunk(.a_string, start, i + 1)
		}
		if line[i] == `"` {
			i++
			for i < line.len - 1 && line[i] != `"` {
				i++
			}
			if i >= line.len {
				i = line.len - 1
			}
			sh.add_chunk(.a_string, start, i + 1)
		}
		// Key
		for i < line.len && is_alpha_underscore(int(line[i])) {
			i++
		}
		word := line[start..i]
		// println('word="$word"')
		if word in sh.keys {
			// println('$word is key')
			sh.add_chunk(.a_key, start, i)
			// println('adding key. len=$vte.chunks.len')
		}
	}
}

fn (vte &VTextEdit) draw_line_chunks(line []rune) {
	// if vte.is_ml_comment {
	// 	vte.gg.draw_text(x, y, line, vte.cfg.comment_cfg)
	// 	return
	// }
	// if vte.chunks.len == 0 {
	// 	// println('no chunks')
	// 	vte.gg.draw_text(x, y, line, vte.cfg.txt_cfg)
	// 	return
	// }

	// mut pos := 0
	// // println('"$line" nr chunks=$vte.chunks.len')
	// // TODO use runes
	// // runes := msg.runes.slice_fast(chunk.pos, chunk.end)
	// // txt := join_strings(runes)
	// for i, chunk in vte.chunks {
	// 	// println('chunk #$i start=$chunk.start end=$chunk.end typ=$chunk.typ')
	// 	// Initial text chunk (not necessarily initial, but the one right before current chunk,
	// 	// since we don't have a seperate chunk for text)
	// 	if chunk.start > pos {
	// 		s := line[pos..chunk.start]
	// 		vte.gg.draw_text(x + pos * vte.char_width, y, s, vte.cfg.txt_cfg)
	// 	}
	// 	// Keyword string etc
	// 	typ := chunk.typ
	// 	cfg := match typ {
	// 		.a_key { vte.cfg.key_cfg }
	// 		.a_string { vte.cfg.string_cfg }
	// 		.a_comment { vte.cfg.comment_cfg }
	// 	}
	// 	s := line[chunk.start..chunk.end]
	// 	vte.gg.draw_text(x + chunk.start * vte.char_width, y, s, cfg)
	// 	pos = chunk.end
	// 	// Final text chunk
	// 	if i == vte.chunks.len - 1 && chunk.end < line.len {
	// 		final := line[chunk.end..line.len]
	// 		vte.gg.draw_text(x + pos * vte.char_width, y, final, vte.cfg.txt_cfg)
	// 	}
	// }
}

fn is_alpha_underscore(r int) bool {
	b := byte(r)
	return (b >= `a` && b <= `z`) || (b >= `A` && b <= `Z`) || (b >= `0` && b <= `9`)
		|| r == ` ` || r == `\t` || b == `_` || b == `#` || b == `$`
}
