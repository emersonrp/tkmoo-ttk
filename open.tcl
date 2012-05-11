

proc window.open_list {} {
    global tkmooVersion
    set o .open_list

    if { [winfo exists $o] == 0 } {

        toplevel $o
        window.configure_for_macintosh $o

        window.bind_escape_to_destroy $o

        window.place_nice $o

        wm iconname $o "Worlds"
        wm title $o "tkMOO-ttk v$tkmooVersion: Worlds"

        listbox $o.lb \
            -height 15 -width 35 \
            -setgrid 1 \
            -background #ffffff \
            -yscroll "$o.sb set"

        bind $o.lb <Button1-ButtonRelease>        "open.do_select"
        bind $o.lb <Double-Button1-ButtonRelease> "open.do_open"
        bind $o.lb <Triple-Button1-ButtonRelease> ""

        bind $o <MouseWheel> {
            .open_list.lb yview scroll [expr - (%D / 120) * 4] units
        }

        ttk::scrollbar $o.sb -command "$o.lb yview"

        ttk::frame $o.f1
        ttk::frame $o.f2

        set bw 6
        ttk::button $o.f1.up   -width $bw -text "Up"   -command "open.do_up"
        ttk::button $o.f1.open -width $bw -text "Open" -command "open.do_open"
        ttk::button $o.f1.edit -width $bw -text "Edit" -command "open.do_edit"
        ttk::button $o.f1.new  -width $bw -text "New"  -command "open.do_new"

        ttk::button $o.f2.down   -width $bw -text "Down"   -command "open.do_down"
        ttk::button $o.f2.copy   -width $bw -text "Copy"   -command "open.do_copy"
        ttk::button $o.f2.delete -width $bw -text "Delete" -command "open.do_delete"
        ttk::button $o.f2.close  -width $bw -text "Close"  -command "destroy $o"

        pack $o.f1.up $o.f1.open $o.f1.edit $o.f1.new \
            -side left \
            -padx 5 -pady 5
        pack $o.f2.down $o.f2.copy $o.f2.delete $o.f2.close \
            -side left \
            -padx 5 -pady 5

        pack $o.f2 -side bottom
        pack $o.f1 -side bottom

        pack $o.sb -side right -fill y
        pack $o.lb -side left -expand 1 -fill both
    }

    worlds.load
    open.fill_listbox
    window.focus $o
}

proc open.fill_listbox {} {
    set o .open_list
    if { [winfo exists $o] == 0 } { return }

    set yview [$o.lb yview]

    $o.lb delete 0 end

    foreach world [worlds.worlds] {
        $o.lb insert end [worlds.get $world Name]
    }

    $o.lb yview moveto [lindex $yview 0]
}

proc open.do_up {} {
    global worlds_worlds
    set o .open_list
    set index [lindex [$o.lb curselection] 0]
    if { $index != {} } {

        set pair [lrange [worlds.worlds] [expr $index - 1] $index]

        if { [llength $pair] != 2 } { return }

        set worlds_worlds [lreplace [worlds.worlds] [expr $index - 1] $index [lindex $pair 1] [lindex $pair 0]]
        worlds.touch
        open.fill_listbox
        open.select_psn [expr $index - 1]
        window.post_connect
    }
}

proc open.do_down {} {
    global worlds_worlds
    set o .open_list
    set index [lindex [$o.lb curselection] 0]
    if { $index != {} } {

    set pair [lrange [worlds.worlds] $index [expr $index + 1]]

    if { [llength $pair] != 2 } { return }

        set worlds_worlds [lreplace [worlds.worlds] $index [expr $index + 1] [lindex $pair 1] [lindex $pair 0]]
        worlds.touch
        open.fill_listbox
        open.select_psn [expr $index + 1]
        window.post_connect
    }
}

proc open.do_open {} {
    set o .open_list
    set index [lindex [$o.lb curselection] 0]


    if { $index != {} } {
        set world [lindex [worlds.worlds] $index]
        client.connect_world $world
        after idle "destroy $o"
    }
}

proc open.do_edit {} {
    set o .open_list
    set index [lindex [$o.lb curselection] 0]
    if { $index != {} } {
        set world [lindex [worlds.worlds] $index]
        preferences.edit $world
    }
}

proc open.do_copy {} {
    set o .open_list
    set index [lindex [$o.lb curselection] 0]
    if { $index != {} } {
        set world [lindex [worlds.worlds] $index]
        set copy [worlds.copy $world [worlds.create_new_world]]

        if { $copy != -1 } {
            worlds.set $copy Name "Copy of [worlds.get $copy Name]"
                open.fill_listbox
                window.post_connect
                set copy [lindex [worlds.worlds] end]
                open.select_world $copy
                preferences.edit $copy
        }
    }
}

proc open.do_delete {} {
    set o .open_list
    set index [lindex [$o.lb curselection] 0]
    if { $index != {} } {
        set world [lindex [worlds.worlds] $index]
        set name [worlds.get $world Name]
        if { [tk_dialog .delete "Delete world" "Really delete '$name'?" {} 0 "Delete" "Cancel"] != 0 } { return }
        worlds.delete $world
        open.fill_listbox
        window.post_connect
    }
}


proc open.do_new {} {
    set new [worlds.create_new_world]
    worlds.set $new Name "New World"
    open.fill_listbox
    window.post_connect
    set new [lindex [worlds.worlds] end]
    open.select_world $new
    preferences.edit $new
}

proc open.select_psn psn {
    set o .open_list
    $o.lb see $psn
    $o.lb selection clear 0 end
    $o.lb selection set $psn
}

proc open.select_world world {
    set o .open_list
    set psn [lsearch -exact [worlds.worlds] $world]
    $o.lb yview $psn
    $o.lb selection clear 0 end
    $o.lb selection set $psn
}


proc open.do_select {} {
    set o .open_list
    set index [lindex [$o.lb curselection] 0]
    if { $index != {} } {
        set world [lindex [worlds.worlds] $index]
        if { [winfo exists .preferences] == 1 } {
            preferences.edit $world
        }
    }
}
#
#

