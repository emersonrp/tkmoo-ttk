proc bindings.control {} {
     if {[tk windowingsystem] eq "aqua"} {
         return "Command"
     } {
         return "Control"
     }
}

proc bindings.ctrl {} {
     if {[tk windowingsystem] eq "aqua"} {
         return "Command-"
     } elseif {[tk windowingsystem] eq "win32"} {
         return "Ctrl+"
     } {
         return "Ctrl-"
     }
}
proc bindings.default {} {
    global bindings_db
    foreach binding [array names bindings_db] {
        if { [regexp {^(.*):(.*)} $binding _ widget event] == 1 } {
            catch { bind $widget $event $bindings_db($binding) }
        }
    }
}

###

set bindings_db(Text:<[bindings.control]-c>)        { ui.copy_selection %W }
set bindings_db(Text:<[bindings.control]-v>)        { ui.paste_selection %W }
set bindings_db(Text:<[bindings.control]-x>)        { ui.delete_selection %W }

set bindings_db(Entry:<[bindings.control]-c>)       { ui.copy_selection %W }
set bindings_db(Entry:<[bindings.control]-v>)       { ui.paste_selection %W }
set bindings_db(Entry:<[bindings.control]-x>)       { ui.delete_selection %W }

set bindings_db(.input:<[bindings.control]-Home>)   { ui.page_top .output }
set bindings_db(.input:<[bindings.control]-End>)    { ui.page_end .output }
set bindings_db(.input:Home>)                       { ui.page_top .input }
set bindings_db(.input:End>)                        { ui.page_end .input }

set bindings_db(.:<Alt-F4>)                         { client.exit }
set bindings_db(.:<[bindings.control]-q>)           { client.exit }

set bindings_db(.input:<Tab>)                       { window.dabbrev; break }

set bindings_db(.input:<ISO_Left_Tab>)              { window.dabbrev backward; break }

set bindings_db(.input:<Shift-Tab>)                 { window.dabbrev backward; break }
set bindings_db(.input:<Key>) {+
    if { ![string match "*Shift*" "%K"] &&
         ![string match "*Tab*" "%K"] &&
         ![string match "*Control*" "%K"] &&
         ![string match "*Command*" "%K"] &&
         ![string match "*Escape*" "%K"]
         }                                          { window.set_dabbrev_target {} }
}

set bindings_db(.input:<Return>)                    { window.ui_input_return }
set bindings_db(.input:<[bindings.control]-p>)      { window.ui_input_up }
set bindings_db(.input:<[bindings.control]-n>)      { window.ui_input_down }
set bindings_db(.input:<Up>)                        { window.ui_input_up }
set bindings_db(.input:<Down>)                      { window.ui_input_down }
set bindings_db(.input:<Next>)                      { ui.page_down .output }
set bindings_db(.input:<Prior>)                     { ui.page_up .output }

set bindings_db(.input:<MouseWheel>) {
    .output yview scroll [expr - (%D / 120) * 4] units
}

set bindings_db(.input:<Button-5>)                  { .output yview scroll 4 units }
set bindings_db(.output:<Button-5>)                 { .output yview scroll 4 units }
set bindings_db(.input:<Button-4>)                  { .output yview scroll -4 units }
set bindings_db(.output:<Button-4>)                 { .output yview scroll -4 units }

set bindings_db(.input:<Shift-Return>)              { tkTextInsert .input "\n"; break }
set bindings_db(.input:<[bindings.control]-Up>)     "[bind Text <Up>]; break"
set bindings_db(.input:<[bindings.control]-Down>)   "[bind Text <Down>]; break"

set bindings_db(.output:<[bindings.control]-v>)     { ui.paste_selection .input;  focus .input }

set bindings_db(.output:<1>)                        { focus .input }
