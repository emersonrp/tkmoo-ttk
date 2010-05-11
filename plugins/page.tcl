client.register page start 60
proc page.start {} {
	mcp21.register dns-com-vmoo-pages 1.0 \
	    dns-com-vmoo-pages-receive page.do-dns-com-vmoo-pages-receive
    }
proc page.do-dns-com-vmoo-pages-receive {} {
# use the correct request_id
    set which current
    catch { set which [request.get current _data-tag] }
    # 4 long lists, we need to splice them...
    set from [request.get $which from]
    set msg [request.get $which msg]
    set msg [lindex [list [string map {", " " "} $msg]] {0 0}]
    set fr $from
    foreach x [mcp21.report_server_packages] {
    if  {[lsearch $x "dns-com-vmoo-userlist"] == 0} {
    set fr [db.get users $from]
}
}
    window.displayCR "[lindex $msg 0] (page in window)"
    pagewindow.display "Page Window: $fr" "$from" [lindex $msg 1]
}

proc pagewindow.display {name from {text ""}} {
    global subwindow_db
    if { [info exists subwindow_db($name:win)] &&
	 [winfo exists $subwindow_db($name:win)] } {
	set win $subwindow_db($name:win)
	set CR "\n"
    } {
	# window doesn't exist, create one
	set win .[util.unique_id subwindow]
	set subwindow_db($name:win) $win
	set subwindow_db($win:name) $name
	toplevel $win
	wm iconname $win $name
	wm title $win $name
	text $win.t -width 40 -height 10 \
	    -highlightthickness 0 \
	    -relief flat \
	    -yscrollcommand "$win.s set"
	scrollbar $win.s \
	    -bd 1 -highlightthickness 0 \
	    -command "$win.t yview"
	entry $win.e \
	    -highlightthickness 0 \
	    -bd 1 \
	    -background [colourdb.get pink]
	bind $win.e <Return> "pagewindow.enter $win $from"
	pack $win.e -side bottom -fill x
	pack $win.s -side right -fill y
	pack $win.t -fill both -expand 1
	window.place_nice $win
	set CR ""
    }
    $win.t configure -state normal
    $win.t insert end "$CR$text"
    $win.t configure -state disabled
    $win.t yview -pickplace end
}

proc pagewindow.enter {win to} {
    global subwindow_db
    set line [$win.e get]
    $win.e delete 0 end
    mcp21.server_notify dns-com-vmoo-pages-send [list [list "to" $to] [list "msg" $line]]
    set fr [db.get users $to]
    pagewindow.display "Page Window: $fr" "$to" "You page \"$line\""
}
