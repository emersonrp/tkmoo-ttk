client.register entry start

proc entry.start {} {
    edittriggers.register_alias entry.display entry.display
}
proc entry.display {name {text ""}} {
  global subwindow_db
  if { [info exists subwindow_db($name:win)] &&
     [winfo exists $subwindow_db($name:win)] } {
    set win $subwindow_db($name:win)
    set CR "\n"
  } {
    set win .[util.unique_id subwindow]
    set subwindow_db($name:win) $win
    set subwindow_db($win:name) $name
    toplevel $win
    wm iconname $win $name
    wm title $win $name
    entry $win.e -textvar user
    bind $win.e <Return> "enter.enter $win"
    pack $win.e -fill x
  }
}
proc enter.enter win {
    global subwindow_db
    set line [$win.e get]
    $win.e delete 0 end
    client.outgoing "FROM_ENTRY $subwindow_db($win:name) $line"
}
