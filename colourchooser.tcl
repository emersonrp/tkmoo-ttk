
global colour_r colour_g colour_b
# init these at start time so that ttk.scale won't gack.
set colour_r 0
set colour_b 0
set colour_g 0

proc colourchooser.create { {callback ""} hexcolour } {
    global c
    global colour_r colour_g colour_b
    global colour_rh colour_gh colour_bh

    set c .colour

    if { [winfo exists $c] == 0 } {

        toplevel $c
        window.configure_for_macintosh $c

        window.bind_escape_to_destroy $c

        window.place_nice $c

        wm title $c "Colour Chooser"
        wm iconname $c "Colour Chooser"

        $c configure -bd 0 -highlightthickness 0

        frame $c.colour -height 40
        pack $c.colour -side top -fill x -expand 1

        # "R" slider
        ttk::frame $c.r
        ttk::scale $c.r.s -from 0 -to 255 -orient horizontal \
            -variable colour_r -command colourchooser.update_colour

        label $c.r.ll -text "R: " -width 3 -justify left -anchor w \
            -bd 0 -highlightthickness 0
        label $c.r.lc -text "$colour_r" -width 50 -justify right -anchor e \
            -textvariable colour_r \
            -bd 0 -highlightthickness 0

        set colour_rh [to_hex $colour_r]
        label $c.r.lch -text "$colour_rh" -width 3 -justify right -anchor e \
            -textvariable colour_rh \
            -bd 0 -highlightthickness 0

        pack $c.r.s -side left
        pack $c.r.lch -side right
        pack $c.r.lc -side right
        pack $c.r.ll -side right

        # "G" slider
        ttk::frame $c.g
        ttk::scale $c.g.s -from 0 -to 255 -orient horizontal \
            -variable colour_g -command colourchooser.update_colour

        label $c.g.ll -text "G: " -width 3 -justify left -anchor w \
            -bd 0 -highlightthickness 0
        label $c.g.lc -text "$colour_g" -width 50 -justify right -anchor e \
            -textvariable colour_g \
            -bd 0 -highlightthickness 0
        set colour_gh [to_hex $colour_g]
        label $c.g.lch -text "$colour_gh" -width 3 -justify right -anchor e \
            -textvariable colour_gh \
            -bd 0 -highlightthickness 0

        pack $c.g.s -side left
        pack $c.g.lch -side right
        pack $c.g.lc -side right
        pack $c.g.ll -side right

        # "B" slider
        ttk::frame $c.b
        ttk::scale $c.b.s -from 0 -to 255 -orient horizontal \
            -variable colour_b -command colourchooser.update_colour

        label $c.b.ll -text "B: " -width 3 -justify left -anchor w \
            -bd 0 -highlightthickness 0
        label $c.b.lc -text "$colour_b" -width 50 -justify right -anchor e \
            -textvariable colour_b \
            -bd 0 -highlightthickness 0
        set colour_bh [to_hex $colour_b]
        label $c.b.lch -text "$colour_bh" -width 3 -justify right -anchor e \
            -textvariable colour_bh \
            -bd 0 -highlightthickness 0

        pack $c.b.s -side left
        pack $c.b.lch -side right
        pack $c.b.lc -side right
        pack $c.b.ll -side right

        ttk::frame $c.buttons
        ttk::button $c.buttons.close -text "Close" -command "destroy $c"
        ttk::button $c.buttons.accept -text " Ok  " -command "eval $callback \$colour_r \$colour_g \$colour_b; destroy $c"

        pack $c.buttons.accept $c.buttons.close -side left -padx 5 -pady 5

        pack $c.r -side top
        pack $c.g -side top
        pack $c.b -side top
        pack $c.buttons -side top

    }


    $c.colour configure -background $hexcolour

    set colour_r [from_hex [string range $hexcolour 1 2]]
    set colour_rh [string range $hexcolour 1 2]

    set colour_g [from_hex [string range $hexcolour 3 4]]
    set colour_gh [string range $hexcolour 3 4]

    set colour_b [from_hex [string range $hexcolour 5 6]]
    set colour_bh [string range $hexcolour 5 6]

    $c.buttons.accept configure -command "eval $callback \$colour_r \$colour_g \$colour_b; destroy $c"

    window.focus $c
    return $c
}

proc colourchooser.update_colour value {
    global c colour_r colour_g colour_b
    global colour_rh colour_gh colour_bh
    $c.colour configure \
        -background "#[to_hex $colour_r][to_hex $colour_g][to_hex $colour_b]"
    set colour_rh [to_hex $colour_r]
    set colour_gh [to_hex $colour_g]
    set colour_bh [to_hex $colour_b]
}

proc to_hex n {
    set n [expr int($n)]
    set hex {0 1 2 3 4 5 6 7 8 9 a b c d e f}
    set hi [lindex $hex [expr $n / 16]]
    set lo [lindex $hex [expr $n % 16]]
    return $hi$lo
}

proc from_hex h {
    set hex {0 1 2 3 4 5 6 7 8 9 a b c d e f}
    set letters [split [string tolower $h] {}]
    set value 0
    foreach letter $letters {
        set value [expr $value * 16]
        set value [expr $value + [lsearch -exact $hex $letter]]
    }
    return $value
}
#
#
