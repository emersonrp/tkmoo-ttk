

client.register edit start
proc edit.start {} {
    global edit_functions
    set edit_functions [list]
    window.menu_tools_add "Editor" {edit.SCedit {} {} {} "Editor" "Editor"}
    global edit_file_matches
    set edit_file_matches [list]
}

proc edit.register { event callback {priority 50} } {
    global edit_registry
    lappend edit_registry($event) [list $priority $callback]
}

proc edit.dispatch { win event args } {
    global edit_registry
    if { [info exists edit_registry($event)] } {
        foreach record [lsort -command edit.sort_registry $edit_registry($event)] {
            eval [lindex $record 1] $win $args
        }
    }
}

proc edit.sort_registry { a b } {
    return [expr [lindex $a 0] - [lindex $b 0]]
}

#


proc edit.add_file_match { title extensions {mactype {}} } {
    global edit_file_matches
    if { $mactype == {} } {
        lappend edit_file_matches [list $title $extensions $mactype]
    } {
        lappend edit_file_matches [list $title $extensions]
    }
}

proc edit.add_toolbar {editor toolbar} {
    global edit_toolbars
    if { [lsearch -exact $edit_toolbars($editor) $toolbar] == -1 } {
        lappend edit_toolbars($editor) $toolbar
    }
 }
proc edit.remove_toolbar {editor toolbar} {
    global edit_toolbars
    set index [lsearch -exact $edit_toolbars($editor) $toolbar]
    if { $index != -1 } {
        set edit_toolbars($editor) [lreplace $edit_toolbars($editor) $index $index]
    }
}

proc edit.add_edit_function {title callback} {
    global edit_functions
    lappend edit_functions [list $title $callback]
}

proc edit.set_text { e lines } {
    set CR ""
    foreach line $lines {
        $e.t insert end "$CR$line"
        set CR "\n"
    }
}

proc edit.get_text e {
    set lines {}
    set last [$e.t index end]
    for {set n 1} {$n < $last} {incr n} {
        set line [$e.t get "$n.0" "$n.0 lineend"]
        lappend lines $line
    }
    return $lines
}

proc edit.SCedit { pre lines post title icon_title {e ""}} {
    if { $e == "" } {
        set e [edit.create $title $icon_title]
    }


    if { $pre == "" } {
        if { $post == "" } {
            set data $lines
        } {
            set data [concat $lines [list $post]]
        }
        } {
        if { $post == "" } {
            set data [concat [list $pre] $lines]
        } {
            set data [concat [list $pre] $lines [list $post]]
        }
    }

    wm title $e $title
    wm iconname $e $icon_title

    edit.set_text $e $data

    $e.t mark set insert 1.0
    edit.show_line_number $e

    focus $e.t

    set from 1.0
    set to [$e.t index end]
    edit.dispatch $e load [list [list range [list $from $to]]]

    return $e
}

proc edit.destroy e {
    global edit_db

    foreach record [array names edit_db "$e,*" ] {
        unset edit_db($record)
    }

    destroy $e
}

proc edit.set_type { e type } {
    global edit_db
    set edit_db($e,type) $type
}

proc edit.get_type e {
    global edit_db
    if { [info exists edit_db($e,type)] } {
        return $edit_db($e,type)
    } {
        return ""
    }
}


proc edit.fs_set_current_filename {e filename} {
    global edit_db
    set edit_db($e,filename) $filename
}

proc edit.fs_get_current_filename e {
    global edit_db
    if { [info exists edit_db($e,filename)] } {
        return $edit_db($e,filename)
    }
    return ""
}

proc edit.fs_open e {
    global edit_file_matches
    set filetypes {
        {{Text Files} {.txt} TEXT}
        {{All Files} {*} TEXT}
    }
    if { $edit_file_matches != {} } {
        set filetypes [concat $filetypes $edit_file_matches]
    }
    set initialdir [pwd]
    set initialfile ""
    set display "Select text file to open"
    set filename [tk_getOpenFile -filetypes $filetypes \
            -initialdir $initialdir \
            -initialfile $initialfile \
            -parent $e \
            -title "$display"]

    if { $filename == "" } {
        return;
    }

    edit.fs_set_current_filename $e $filename


    set tmp {}
    set fh ""
    catch { set fh [open $filename "r"] }
    if { $fh == "" } {
        window.displayCR "Can't open $filename..." window_highlight
        return
    }

    while { [gets $fh line] != -1 } {
        lappend tmp $line
    }
    close $fh

    $e.t delete 1.0 end

    set CR ""
    foreach line $tmp {
        $e.t insert insert "$CR$line"
        set CR "\n"
    }

    $e.t mark set insert 1.0
    edit.show_line_number $e
}

proc edit.fs_save e {
    set filename [edit.fs_get_current_filename $e]
    if { $filename == "" } {
        edit.fs_save_as $e
        return
    }

    set tmp {}
    set len [lindex [split [$e.t index end] "." ] 0]
    for {set i 1} {$i < $len} {incr i} {
        set line [$e.t get "$i.0" "$i.0 lineend"]
        lappend tmp $line
    }

    set fh ""
    catch { set fh [open $filename "w"] }
    if { $fh == "" } {
        window.displayCR "Can't open $filename..." window_highlight
        return
    }

    set CR ""
    foreach line $tmp {
        puts -nonewline $fh "$CR$line"
        set CR "\n"
    }
    close $fh

}

proc edit.fs_save_as e {
    global edit_file_matches
    set filetypes {
    {{Text Files} {.txt} TEXT}
        {{All Files} {*} TEXT}
    }
    if { $edit_file_matches != {} } {
        set filetypes [concat $filetypes $edit_file_matches]
    }
    set file [edit.fs_get_current_filename $e]
    if { $file == "" } {
        set initialdir [pwd]
        set initialfile ""
    } {
        set initialdir [file dirname $file]
        set initialfile [file tail $file]
    }
    set display "Select text file to save"
    set filename [tk_getSaveFile -filetypes $filetypes \
            -initialdir $initialdir \
            -initialfile $initialfile \
            -parent $e \
            -title "$display"]
    if { $filename == "" } {
        return
    }

    set tmp {}
    set len [lindex [split [$e.t index end] "." ] 0]
    for {set i 1} {$i < $len} {incr i} {
        set line [$e.t get "$i.0" "$i.0 lineend"]
        lappend tmp $line
    }

    set fh ""
    catch { set fh [open $filename "w"] }
    if { $fh == "" } {
        window.displayCR "Can't open $filename..." window_highlight
        return
    }

    set CR ""
    foreach line $tmp {
        puts -nonewline $fh "$CR$line"
        set CR "\n"
    }
    close $fh

    edit.fs_set_current_filename $e $filename
}

proc edit.create { title icon_title } {

    global tkmooLibrary

    global edit_toolbars


    ### something like...

    set w .[util.unique_id "e"]

    set edit_toolbars($w) {}

    toplevel $w

    window.place_nice $w

    $w configure -bd 0 -highlightthickness 0

    wm title $w $title
    wm iconname $w $icon_title

    menu $w.controls -tearoff 0 -relief raised -bd 1
    $w configure -menu $w.controls

    $w.controls add cascade -label "File" -menu $w.controls.file \
    -underline 0

    menu $w.controls.file -tearoff 0

    $w.controls.file add command \
        -label "Open..." \
        -underline 0 \
        -command "edit.fs_open $w"
    window.hidemargin $w.controls.file

    $w.controls.file add command \
        -label "Save" \
        -underline 0 \
        -command "edit.fs_save $w"
    window.hidemargin $w.controls.file

    $w.controls.file add command \
        -label "Save As..." \
        -underline 5 \
        -command "edit.fs_save_as $w"
    window.hidemargin $w.controls.file

    $w.controls.file add separator
    window.hidemargin $w.controls.file

    $w.controls.file add command \
        -label "Send" \
        -underline 1 \
        -command "edit.send $w"
    window.hidemargin $w.controls.file

    $w.controls.file add command \
        -label "Send and Close" \
        -underline 10 \
        -command "edit.send_and_close $w"
    window.hidemargin $w.controls.file

    $w.controls.file add command \
        -label "Close" \
        -underline 0 \
        -command "edit.destroy $w"
    window.hidemargin $w.controls.file

    $w.controls add cascade -label "Edit" -menu $w.controls.edit \
    -underline 0

    menu $w.controls.edit -tearoff 0
    $w.controls.edit add command \
        -label "Cut" \
        -accelerator "[window.accel Ctrl]+X" \
        -command "edit.do_cut $w"
    window.hidemargin $w.controls.edit
        $w.controls.edit add command \
        -label "Copy" \
        -accelerator "[window.accel Ctrl]+C" \
        -command "edit.do_copy $w"
    window.hidemargin $w.controls.edit
        $w.controls.edit add command \
        -label "Paste" \
        -accelerator "[window.accel Ctrl]+V" \
        -command "edit.do_paste $w"
    window.hidemargin $w.controls.edit

    global edit_functions
    if { $edit_functions != {} } {
        $w.controls.edit add separator
        window.hidemargin $w.controls.edit
        foreach function $edit_functions {
            set title [lindex $function 0]
            set callback [lindex $function 1]
            $w.controls.edit add command \
                -label "$title" \
                -command "$callback $w"
            window.hidemargin $w.controls.edit
        }
    }

    $w.controls add cascade -label "View" -menu $w.controls.view \
    -underline 0

    menu $w.controls.view -tearoff 0
    $w.controls.view add command \
        -label "Find" \
        -underline 0 \
        -command "edit.find $w"
    window.hidemargin $w.controls.view
        $w.controls.view add command \
        -label "Goto" \
        -underline 0 \
        -command "edit.goto $w"
    window.hidemargin $w.controls.view

    text $w.t \
        -font [fonts.fixedwidth] \
        -height 24 \
        -width 80 \
        -yscrollcommand "$w.scrollbar set" \
    -highlightthickness 0 \
        -setgrid true

    ttk::scrollbar $w.scrollbar -command "$w.t yview"

    ttk::label $w.position -text "position: 1.0" -anchor e

    bind $w.t <KeyPress>     "after idle edit.show_line_number $w"
    bind $w.t <KeyRelease>     "after idle edit.show_line_number $w"
    bind $w.t <ButtonPress>     "after idle edit.show_line_number $w"
    bind $w.t <ButtonRelease>     "after idle edit.show_line_number $w"

    bind $w.t <Control-v>    "edit.do_paste $w; break"

    edit.repack $w

    return $w
}

proc edit.repack editor {
    global edit_toolbars

    set slaves [pack slaves $editor]

    if { $slaves != "" } {
        eval pack forget $slaves
    }

    foreach toolbar $edit_toolbars($editor) {
        pack $editor.$toolbar -side top -fill x
    }

    pack $editor.position -fill x -side bottom
    pack $editor.scrollbar -side right -fill y
    pack $editor.t -side left -expand 1 -fill both
}

proc edit.show_line_number w {
    if { [winfo exists $w] == 0 } { return }
    set line_number [$w.t index insert]
    $w.position configure -text "position: $line_number"
}

proc edit.dot_quote_line line {
    if { $line == "." } { return ".." };
    return $line
}

proc edit.dot_quote_lines lines {
    set tmp {}
    foreach line $lines {
        lappend tmp [edit.dot_quote_line $line]
    }
    return $tmp
}


proc edit.send w {
    set last [$w.t index end]
    for {set n 1} {$n < $last} {incr n} {
        set line [$w.t get "$n.0" "$n.0 lineend"]
        io.outgoing $line
    }
}

proc edit.send_and_close w {
    set last [$w.t index end]
    for {set n 1} {$n < $last} {incr n} {
        set line [$w.t get "$n.0" "$n.0 lineend"]
        io.outgoing $line
    }
    edit.destroy $w
}


proc edit.configure_send { e label command {underline 0} } {
    $e.controls.file entryconfigure 4 \
        -label $label -command $command -underline $underline
}

proc edit.configure_send_and_close { e label command {underline 0} } {
    $e.controls.file entryconfigure 5 \
        -label $label -command $command -underline $underline
}

proc edit.configure_close { e label command {underline 0} } {
    $e.controls.file entryconfigure 6 \
        -label $label -command $command -underline $underline
}

###

proc edit.find w {
    set f $w.find

    if { [winfo exists $f] == 0 } {
        toplevel $f

        window.bind_escape_to_destroy $f

        window.place_nice $f $w

        $f configure -bd 0 -highlightthickness 0

        wm title $f "Find and Replace"
        wm iconname $f "Find and Replace"
        ttk::frame $f.t
        ttk::label $f.t.l -text "Find:" -width 8 -anchor w
        ttk::entry $f.t.e -width 40
        pack $f.t.l -side left
        pack $f.t.e -side right

        ttk::frame $f.m
        ttk::label $f.m.l -text "Replace:" -width 8 -anchor w
        ttk::entry $f.m.e -width 40
        pack $f.m.l -side left
        pack $f.m.e -side right

        ttk::frame $f.b
        ttk::button $f.b.ffind -text "Find >" -command "edit.do_find $w forwards"
        ttk::button $f.b.bfind -text "< Find" -command "edit.do_find $w backwards"
        ttk::button $f.b.replace -text "Replace" -command "edit.do_replace $w"
        ttk::button $f.b.replacea -text "Replace all" -command "edit.do_replace_all $w"
        ttk::button $f.b.close -text "Close" -command "destroy $f"

        pack $f.b.ffind $f.b.bfind $f.b.replace $f.b.replacea $f.b.close \
            -side left -padx 5 -pady 5

        pack $f.t -side top -fill x
        pack $f.m -side top -fill x
        pack $f.b -side bottom
    }

    after idle "wm deiconify $f; window.focus $f.t.e"

    $f.t.e delete 0 end
    catch {$f.t.e insert 0 [selection get]}
}

proc edit.do_find { w direction } {
    set string [$w.find.t.e get]
    if { $string == "" } {
        return 0
    }


    switch $direction {
        forwards {
            set from [$w.t index "insert + 1 char"]
        }
        backwards {
            set from [$w.t index "insert - 1 char"]
        }
    }

    set psn [$w.t search -$direction -count length -- $string $from]
    if {$psn != ""} {
        $w.t tag remove sel 0.0 end
        ::tk::TextScrollPages $w.t $psn
        $w.t tag add sel $psn "$psn + $length char"
        edit.show_line_number $w
        return 1
    }
    return 0
}

proc edit.do_replace w {
    set string [$w.find.m.e get]
    catch {
        tk_textCut $w.t
        $w.t insert insert $string
    }
}

proc edit.do_replace_all w {
    set find [$w.find.t.e get]
    set replace [$w.find.m.e get]

    if { $find == $replace } { return }

    $w.t mark set edit_URHERE insert
    $w.t mark gravity edit_URHERE left

    set lreplace [string length $replace]

    set psn "0.0"
    while { [set psn [$w.t search -forwards -count length -- $find $psn end]] != "" } {
        $w.t tag remove sel 0.0 end
        ::tk::TextScrollPages $w.t $psn
        $w.t tag add sel $psn "$psn + $length char"
        edit.do_replace $w
        set psn [$w.t index "$psn + $lreplace char"]
    }

    $w.t mark set insert edit_URHERE
    $w.t mark unset edit_URHERE

    $w.t see insert

    edit.show_line_number $w
}

###

proc edit.goto w {
    set f $w.goto


    if { [winfo exists $f] == 0 } {
        toplevel $f

        window.bind_escape_to_destroy $f

        window.place_nice $f $w

        $f configure -bd 0 -highlightthickness 0

        wm title $f "Goto Line Number"
        wm iconname $f "Goto Line"
        ttk::frame $f.t
        ttk::label $f.t.l -text "Line Number:"
        ttk::entry $f.t.e
        pack $f.t.l -side left
        pack $f.t.e -side right

        ttk::frame $f.b
        ttk::button $f.b.goto -text "Goto" -command "edit.do_goto $w"
        ttk::button $f.b.close -text "Close" -command "destroy $f"

        pack $f.b.goto $f.b.close -side left \
            -padx 5 -pady 5

        pack $f.t -side top -fill x
        pack $f.b -side bottom

        bind $f <Return> "edit.do_goto $w"
    }

    after idle "wm deiconify $f; window.focus $f.t.e"

    $f.t.e delete 0 end
    catch {$f.t.e insert 0 [selection get]}
}

proc edit.do_goto w {
    set string [$w.goto.t.e get]
    if { $string == "" } {
        return
    }
    catch { ::tk::TextScrollPages $w.t $string.0 }
    destroy $w.goto
    edit.show_line_number $w
}

###

proc edit.do_cut w {
    if { [lsearch -exact [$w.t tag names] sel] != -1 } {
        set from [$w.t index sel.first]
    }
    ui.delete_selection $w.t
}
proc edit.do_copy w {
    ui.copy_selection $w.t
}
proc edit.do_paste w {
    set from [$w.t index insert]
    ui.paste_selection $w.t
    set to [$w.t index insert]
    edit.dispatch $w load [list [list range [list $from $to]]]
}
#
#
