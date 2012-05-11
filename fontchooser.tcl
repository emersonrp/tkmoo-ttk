
proc fontchooser.do_select {} {
    set fc .fontchooser
    set family [$fc.f.l get [$fc.f.l curselection]]
    fontchooser.change_font_db -family $family
    fontchooser.update_tag
}

proc fontchooser.string_to_actual string {
    if { [catch { set actual [font actual "$string"] }] == 1 } {
        set actual [font actual does_not_exist]
    }
    return $actual
}

proc fontchooser.destroy w {
    global fontchooser_db
    unset fontchooser_db
    destroy $w
}

proc fontchooser.create { {callback ""} font } {
    fontchooser.font_to_db $font

    set fc .fontchooser

    if { [winfo exists $fc] == 0 } {
        toplevel $fc -bd 0 -highlightthickness 0

        window.place_nice $fc

        wm title $fc "Font Chooser"
        wm iconname $fc "Font Chooser"

        text $fc.t \
            -height 2 -width 20 \
            -bd 1 -highlightthickness 0 \
            -background [colourdb.get pink]

        $fc.t insert insert "The quick brown fox 01234 !&*#$%"
        $fc.t configure -state disabled
        $fc.t tag add font_style 1.0 end

        ttk::frame $fc.con
        ttk::button $fc.con.accept -text " Ok  " \
                -command "eval $callback [fontchooser.db_to_font]; fontchooser.destroy $fc"
        ttk::button $fc.con.close -text "Close" \
                -command "fontchooser.destroy $fc"
        pack $fc.con.accept $fc.con.close -side left -padx 5 -pady 5

        pack $fc.con -side bottom
        pack $fc.t -side bottom -fill x

        ttk::frame $fc.f
        pack $fc.f -side left -fill both -expand 1

        listbox $fc.f.l -height 10 \
            -bd 1 -highlightthickness 0 \
            -yscroll "$fc.f.s set" \
            -background #ffffff \
            -setgrid 1

        bind $fc <MouseWheel> {
            .fontchooser.f.l yview scroll [expr - (%D / 120) * 4] units
        }

        bind $fc.f.l <Button1-ButtonRelease> "fontchooser.do_select"

        pack $fc.f.l -side left -fill both -expand 1

        set families [lsort [font families]]

        foreach family $families {
            $fc.f.l insert end $family
        }

        ttk::scrollbar $fc.f.s -command "$fc.f.l yview"
        pack $fc.f.s -side right -fill y

        ttk::frame $fc.r
        pack $fc.r -side right -fill y

        ttk::frame $fc.r.weight
        pack $fc.r.weight -side top

        label $fc.r.weight.l -text "weight:" -width 6 -justify right -anchor e
        pack $fc.r.weight.l -side left -fill x

        set weights {normal bold}
        ttk::menubutton $fc.r.weight.b \
            -text "[lindex $weights 0]" \
            -menu $fc.r.weight.b.m
        pack $fc.r.weight.b -side left

        menu $fc.r.weight.b.m -tearoff 0
        foreach weight {normal bold} {
            $fc.r.weight.b.m add command \
                -label $weight \
                -command "fontchooser.change_font_db -weight $weight;fontchooser.update_tag; $fc.r.weight.b configure -text $weight"
        }

        frame $fc.r.slant
        pack $fc.r.slant -side top

        label $fc.r.slant.l -text "slant:" -width 6 -justify right -anchor e
        pack $fc.r.slant.l -side left -fill x

        set slants {roman italic}
        ttk::menubutton $fc.r.slant.b \
                -text "[lindex $slants 0]" \
                -menu $fc.r.slant.b.m
        pack $fc.r.slant.b -side left

        menu $fc.r.slant.b.m -tearoff 0
        foreach slant {roman italic} {
            $fc.r.slant.b.m add command \
                -label $slant \
                -command "fontchooser.change_font_db -slant $slant;fontchooser.update_tag; $fc.r.slant.b configure -text $slant"
        }

        frame $fc.r.size
        pack $fc.r.size -fill x -side top

        label $fc.r.size.l -text "size:" -width 6 -justify right -anchor e
        pack $fc.r.size.l -side left -fill x

        entry $fc.r.size.e -width 3 -bd 1 -highlightthickness 0 -bg [colourdb.get pink]
        pack $fc.r.size.e -side left
        bind $fc.r.size.e <Leave> "fontchooser.set_size"
        bind $fc.r.size.e <Return> "fontchooser.set_size"

    }

    $fc.r.weight.b configure -text [fontchooser.db_value -weight]

    $fc.r.slant.b  configure -text [fontchooser.db_value -slant]

    set index [lsearch -exact [$fc.f.l get 0 end] [fontchooser.db_value -family]]
    $fc.f.l selection clear 0 end
    $fc.f.l selection set $index
    $fc.f.l see $index

    $fc.r.size.e delete 0 end
    $fc.r.size.e insert insert [fontchooser.db_value -size]

    $fc.con.accept configure \
    -command "fontchooser.work_it_out [list $callback]; fontchooser.destroy $fc"

    fontchooser.update_tag

    window.focus $fc
}

proc fontchooser.set_size {} {
    set fc .fontchooser
    set v [$fc.r.size.e get]
    set default_size 8
    set size $default_size
    catch { set size [expr 0 + [lindex $v 0]] }
    if { $size <= 0 } { set size $default_size };

    fontchooser.change_font_db -size $size
    fontchooser.update_tag

    $fc.r.size.e delete 0 end
    $fc.r.size.e insert insert $size
}

proc fontchooser.work_it_out { callback } {
    eval $callback [fontchooser.db_to_font]
}

proc fontchooser.font_to_db font {
    global fontchooser_db
    foreach {k v} [fontchooser.string_to_actual $font] {
        set fontchooser_db($k) $v
    }
}

proc fontchooser.db_to_font {} {
    global fontchooser_db
    return "{$fontchooser_db(-family)} $fontchooser_db(-size) $fontchooser_db(-weight) $fontchooser_db(-slant)"
}

proc fontchooser.change_font_db args {
    global fontchooser_db
    foreach {k v} $args {
        set fontchooser_db($k) $v
    }
    fontchooser.font_to_db [fontchooser.db_to_font]
}

proc fontchooser.db_value key {
    global fontchooser_db
    return $fontchooser_db($key)
}

proc fontchooser.update_tag {} {
    set fc .fontchooser
    $fc.t tag configure font_style -font "[fontchooser.db_to_font]"
}
#
#
