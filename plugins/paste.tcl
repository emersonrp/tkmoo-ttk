client.register paste start

proc paste.start {} {
    window.menu_tools_add "@paste" paste.toggle
    global paste
    set paste .[util.unique_id paste]
    
    }
    
proc paste.toggle {} { 
global paste
if {[winfo exists $paste] == 1 } {
paste.destroy
} { paste.create }
}

proc paste.destroy {} {
global paste
 if { [winfo exists $paste] == 1 } {
        destroy $paste
    }
}

proc paste.create {} {
global paste
toplevel $paste
wm title $paste "paste selection"
frame $paste.text
frame $paste.option
frame $paste.option.entry
frame $paste.send
text $paste.text.text
global pas
tk_optionMenu $paste.option.option pas @paste @paste-to @xpaste
label $paste.option.entry.l -text " "
entry $paste.option.entry.e
button $paste.send.send -text "Send" -command {paste.send [$paste.text.text get 1.0 end]}
pack $paste.text.text
pack $paste.text -side top
pack $paste.option.option -side left
pack $paste.option.entry -side right
pack $paste.option.entry.l -side left
pack $paste.option.entry.e -side right
pack $paste.send.send
pack $paste.send -side bottom
pack $paste.option -side bottom
}

proc paste.send txt {
global pas
io.outgoing $pas
io.outgoing $txt
io.outgoing "."
}