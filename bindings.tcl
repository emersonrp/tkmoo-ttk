
proc bindings.bindings {} {
    return [list emacs tf windows macintosh default]
}

proc bindings.default {} {
    global bindings_db window_binding
    foreach binding [array names bindings_db] {
    if { [regexp {^(.*):default:(.*)} $binding _ widget event] == 1 } {
        catch { bind $widget $event $bindings_db($binding) }
    }
    }
    set window_binding default
}


proc bindings.set emulate {
    global bindings_db window_binding
    bindings.default
    if { $emulate == "default" } {
    return
    }
    foreach binding [array names bindings_db] {
    if { [regexp {^(.*):(.*):(.*)} $binding _ widget emul event] == 1 } {
        if { ($emulate == $emul) } {
            set bindings_db($widget:default:$event) [bind $widget $event]
            catch { bind $widget $event $bindings_db($binding) }
        }
    }
    }
    set window_binding $emulate
}

###
#
set bindings_db(Text:emacs:<Left>)         { ui.left_char %W }
set bindings_db(Text:emacs:<Right>)         { ui.right_char %W }
set bindings_db(Text:emacs:<Down>)         { ui.down_line %W }
set bindings_db(Text:emacs:<Up>)         { ui.up_line %W }
set bindings_db(Text:emacs:<Control-b>)     { ui.left_char %W }
set bindings_db(Text:emacs:<Control-f>)     { ui.right_char %W }
set bindings_db(Text:emacs:<Control-n>)     { ui.down_line %W }
set bindings_db(Text:emacs:<Control-p>)     { ui.up_line %W }
set bindings_db(Text:emacs:<Control-a>)     { ui.start_line %W }
set bindings_db(Text:emacs:<Control-e>)     { ui.end_line %W }
set bindings_db(Text:emacs:<Control-v>)     { ui.page_down %W }

set bindings_db(Text:emacs:<Alt-w>)         { ui.copy_selection %W }
set bindings_db(Text:emacs:<Control-y>)     { ui.paste_selection %W }
set bindings_db(Text:emacs:<Control-w>)     { ui.delete_selection %W }
set bindings_db(Entry:emacs:<Alt-w>)         { ui.copy_selection %W }
set bindings_db(Entry:emacs:<Control-y>)     { ui.paste_selection %W }
set bindings_db(Entry:emacs:<Control-w>)     { ui.delete_selection %W }
set bindings_db(.output:emacs:<Control-y>)     { ui.paste_selection .input; focus .input }

set bindings_db(Text:emacs:<Escape>v)         { ui.page_up %W }

set bindings_db(Text:tf:<Control-b>)     { ui.left_word_start %W }
set bindings_db(Text:tf:<Control-f>)     { ui.right_word_start %W }
set bindings_db(Text:tf:<Control-u>)     { ui.delete_line %W }
set bindings_db(Text:tf:<Control-k>)     { ui.delete_to_end %W }
set bindings_db(Text:tf:<Control-d>)     { ui.delete_char_right %W }
set bindings_db(Text:tf:<Escape>k)     { ui.delete_to_beginning %W }
set bindings_db(Entry:tf:<Control-b>)     { ui.left_word_start_entry %W }
set bindings_db(Entry:tf:<Control-f>)     { ui.right_word_start_entry %W }
set bindings_db(Entry:tf:<Control-u>)     { ui.delete_line_entry %W }
set bindings_db(Entry:tf:<Control-k>)     { ui.delete_to_end_entry %W }
set bindings_db(Entry:tf:<Escape>k)     { ui.delete_to_beginning_entry %W }
set bindings_db(.input:tf:<Control-l>)     { ui.clear_screen .output }
set bindings_db(.input:tf:<Up>)        { ui.up_line %W }
set bindings_db(.input:tf:<Down>)    { ui.down_line %W }


set bindings_db(Text:windows:<Control-c>)     { ui.copy_selection %W }
set bindings_db(Text:windows:<Control-v>)     { ui.paste_selection %W }
set bindings_db(Text:windows:<Control-x>)     { ui.delete_selection %W }

set bindings_db(Entry:windows:<Control-c>)     { ui.copy_selection %W }
set bindings_db(Entry:windows:<Control-v>)     { ui.paste_selection %W }
set bindings_db(Entry:windows:<Control-x>)     { ui.delete_selection %W }
set bindings_db(.input:windows:<Alt-n>)     { wm iconify . }

set bindings_db(.input:windows:<Control-Home>) { ui.page_top .output }
set bindings_db(.input:windows:<Control-End>) { ui.page_end .output }

set bindings_db(Text:macintosh:<Command-c>)    { ui.copy_selection %W }
set bindings_db(Text:macintosh:<Command-v>)    { ui.paste_selection %W }
set bindings_db(Text:macintosh:<Command-x>)    { ui.delete_selection %W }
#set bindings_db(.:macintosh:<Command-q>)    { client.exit }


set bindings_db(Text:macintosh:<Command-a>) [bind Text <Control-slash>]
set bindings_db(Entry:macintosh:<Command-a>) [bind Entry <Control-slash>]

set bindings_db(.input:macintosh:<Command-Home>) { ui.page_top .output }
set bindings_db(.input:macintosh:<Command-End>) { ui.page_end .output }

set bindings_db(.:default:<Alt-F4>)     { client.exit }


set bindings_db(.input:default:<Tab>) { window.dabbrev; break }

set bindings_db(.input:default:<ISO_Left_Tab>) { window.dabbrev backward; break }

set bindings_db(.input:default:<Shift-Tab>) { window.dabbrev backward; break }
set bindings_db(.input:default:<Key>) {+
    if { ![string match "*Shift*" "%K"] &&
         ![string match "*Tab*" "%K"] &&
         ![string match "*Control*" "%K"] &&
         ![string match "*Command*" "%K"] &&
         ![string match "*Escape*" "%K"]
         } {
        window.set_dabbrev_target {}
    }
}

set bindings_db(.input:default:<Return>)    { window.ui_input_return }
set bindings_db(.input:default:<Control-p>) { window.ui_input_up }
set bindings_db(.input:default:<Control-n>) { window.ui_input_down }
set bindings_db(.input:default:<Up>)        { window.ui_input_up }
set bindings_db(.input:default:<Down>)      { window.ui_input_down }
set bindings_db(.input:default:<Next>)         { ui.page_down .output }
set bindings_db(.input:default:<Prior>)     { ui.page_up .output }

set bindings_db(.input:default:<MouseWheel>) {
    .output yview scroll [expr - (%D / 120) * 4] units
}

set bindings_db(.input:default:<Button-5>) { .output yview scroll 4 units }
set bindings_db(.output:default:<Button-5>) { .output yview scroll 4 units }
set bindings_db(.input:default:<Button-4>) { .output yview scroll -4 units }
set bindings_db(.output:default:<Button-4>) { .output yview scroll -4 units }

set bindings_db(.input:default:<Shift-Return>)     { tkTextInsert .input "\n"; break }
set bindings_db(.input:default:<Control-Up>)     "[bind Text <Up>]; break"
set bindings_db(.input:default:<Control-Down>)     "[bind Text <Down>]; break"

set bindings_db(.output:default:<Control-v>)       { ui.paste_selection .input;  focus .input }

set bindings_db(.output:default:<1>)    { focus .output }
set bindings_db(.output:default:<Button1-ButtonRelease>) {
    set sel ""
    catch { set sel [selection get -displayof .output] }
    if { "x$sel" == "x" } {
        focus .input
    }
}
