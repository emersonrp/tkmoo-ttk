

proc ui.page_top win {
    ::tk::TextScrollPages $win 1.0
}
proc ui.page_end win {
    ::tk::TextScrollPages $win {end - 1 char}
}

proc ui.paste_selection win { 
    tk_textPaste $win 
    global tcl_platform
    if { $tcl_platform(platform) == "macintosh" &&
         "$win" == ".input" } {
        focus .input
    }
}

proc ui.delete_selection win { 
    tk_textCut $win
}

proc ui.copy_selection win { 
    set selection ""
    catch { set selection [selection get] }
 
    if { "x$selection" != "x" } { 
        clipboard clear
        clipboard append $selection
    } {
        tk_textCopy $win
    }
}

proc ui.page_down win { 
    ::tk::TextScrollPages $win [::tk::TextScrollPages $win 1]
}

proc ui.page_up win { 
    ::tk::TextScrollPages $win [::tk::TextScrollPages $win -1]
}

proc ui.clear_screen win { 
    window.clear_screen $win
}

proc ui.delete_line win {
    $win delete {insert linestart} {insert lineend}
}

proc ui.delete_line_entry win {
    $win delete 0 end
}

proc ui.left_char win {
    ::tk::TextScrollPages $win insert-1c
}

proc ui.right_char win {
    ::tk::TextScrollPages $win insert+1c
}

proc ui.up_line win {
    ::tk::TextScrollPages $win [tkTextUpDownLine $win -1]
}

proc ui.down_line win {
    ::tk::TextScrollPages $win [tkTextUpDownLine $win 1]
}

proc ui.start_line win {
    ::tk::TextScrollPages $win {insert linestart}
}

proc ui.end_line win {
    ::tk::TextScrollPages $win {insert lineend}
}

proc ui.left_word_start win {
    $win mark set insert {insert-1c wordstart}
    while { [$win get insert {insert+1c}] == " " } {
	ui.left_char $win
    }
    $win mark set insert {insert wordstart}
}

proc ui.left_word_start_entry win {
    tkEntrySetCursor $win  [string wordstart [$win get] [expr [$win index insert] - 1]]
}

proc ui.right_word_start win {
    $win mark set insert {insert wordend}
    while { [$win get insert {insert+1c}] == " " } {
	ui.right_char $win
    }
}

proc ui.right_word_start_entry win {
    tkEntrySetCursor $win [string wordend [$win get] [$win index insert]]
}

proc ui.delete_to_end win {
    if [$win compare insert == {insert lineend}] {
        $win delete insert
    } else {
        $win delete insert {insert lineend}
    }
}

proc ui.delete_to_end_entry win {
    $win delete insert end
}

proc ui.delete_to_beginning win {
    $win delete {insert linestart} insert
}

proc ui.delete_to_beginning_entry win {
    $win delete 0 insert
}

proc ui.delete_word_right win {
    $win delete insert {insert wordend}
}

proc ui.delete_word_left win {
    $win delete {insert -1c wordstart} insert
}

proc ui.delete_char_right win {
    $win delete insert {insert +1c} 
}

proc ui.delete_char_left win {
    $win delete {insert -1c} insert
}
#
#

