

client.register whiteboard start
proc whiteboard.start {} {
    global whiteboard_funky
    global whiteboard_funky_bitmaps
    global whiteboard_width
    global whiteboard_height
    global whiteboard_margin

    set whiteboard_funky 1

    array set whiteboard_funky_bitmaps {
        line	line.xbm
        rectangle	rect.xbm
        oval	oval.xbm
        arrow	arro.xbm
        text	atoz.xbm
        move	slct.xbm
    }

    set whiteboard_width 600
    set whiteboard_height 400
    set whiteboard_margin 10
}

proc whiteboard.set_handler { whiteboard handler } {
    global whiteboard_handler
    set whiteboard_handler($whiteboard) $handler
}
proc whiteboard.get_handler whiteboard {
    global whiteboard_handler
    return $whiteboard_handler($whiteboard)
}


proc whiteboard.initialise {} {
    global whiteboard_colours whiteboard_contrast whiteboard_colour
    set whiteboard_colours { red orange yellow green blue black white }
    array set whiteboard_contrast {
	red	black
	orange	black
	yellow	black
	green	black
	blue	white
	black	white
	white	black
    }
    set whiteboard_colour           black
}


### hooks for XMCP or regular XMCP
#
#

proc whiteboard.SCshow { object title } {
    global whiteboard_whiteboard
    if { [info exists whiteboard_whiteboard($object)] } {
        set wb $whiteboard_whiteboard($object)
        $wb.draw.canvas delete all
    } {
        set wb [whiteboard.create $title]
        set whiteboard_whiteboard($object) $wb
    }
    after idle "wm deiconify $wb; raise $wb"
    return $wb
}

proc whiteboard.SCline { object x1 y1 x2 y2 colour } {
    global whiteboard_whiteboard
    if { [info exists whiteboard_whiteboard($object)] } {
        set dt $whiteboard_whiteboard($object)
        $dt.draw.canvas create line $x1 $y1 $x2 $y2 \
            -width 2 -fill [colourdb.get $colour]
    }
}

proc whiteboard.SCdelete { object id } {
    global whiteboard_whiteboard 
    if { [info exists whiteboard_whiteboard($object)] } {
        set dt $whiteboard_whiteboard($object)
        set item [whiteboard.id_to_item $id]
        $dt.draw.canvas delete $item
    }
}

proc whiteboard.SCmove { object id dx dy } {
    global whiteboard_whiteboard 
    if { [info exists whiteboard_whiteboard($object)] } {
        set dt $whiteboard_whiteboard($object)
        set item [whiteboard.id_to_item $id]
        $dt.draw.canvas move $item $dx $dy
    } {
        window.displayOutput "Can't find o: $object, i: $id\n" ""
    }
}  

proc whiteboard.SCdraw { object x1 y1 x2 y2 colour pen id text } {
    global whiteboard_whiteboard whiteboard_id
    if { [info exists whiteboard_whiteboard($object)] } {
        set dt $whiteboard_whiteboard($object)
        switch $pen {
            arrow {
                set identifier [$dt.draw.canvas create line \
                    $x1 $y1 $x2 $y2 \
                    -width 2 -fill [colourdb.get $colour] -arrow last] 
            }
            line {
                set identifier [$dt.draw.canvas create line \
                    $x1 $y1 $x2 $y2 \
                    -width 2 -fill [colourdb.get $colour]]
            }
            rectangle {
                set identifier [$dt.draw.canvas create rectangle \
                    $x1 $y1 $x2 $y2 \
                    -width 2 -outline [colourdb.get $colour]]
            }
            oval {
                set identifier [$dt.draw.canvas create oval \
                    $x1 $y1 $x2 $y2 \
                    -width 2 -outline [colourdb.get $colour]]
            }
            text {
                set identifier [$dt.draw.canvas create text $x1 $y1 \
                    -text "$text" -fill [colourdb.get $colour]]
            }
        }
        set whiteboard_id($identifier) $id
    }
}

proc whiteboard.SCclean object {
    global whiteboard_whiteboard
    if { [info exists whiteboard_whiteboard($object)] } {
        set dt $whiteboard_whiteboard($object)
        $dt.draw.canvas delete all
    }
}

proc whiteboard.SCgallery { object lines } {
    global whiteboard_whiteboard

    set loader $whiteboard_whiteboard($object).load

    catch {destroy $loader}

    toplevel $loader

    window.place_nice $loader

    $loader configure -bd 0 

    wm title $loader "Gallery"

    frame $loader.f
    scrollbar $loader.f.s -command "$loader.f.l yview" \
	-highlightthickness 0
    window.set_scrollbar_look $loader.f.s

    listbox $loader.f.l -yscroll "$loader.f.s set" \
	-highlightthickness 0 \
	-setgrid 1 \
	-background #ffffff \
	-height 10
    pack $loader.f.s -side right -fill y 
    pack $loader.f.l -side left -fill x

    entry $loader.e -font [fonts.fixedwidth]

    frame $loader.c 
    frame $loader.c.t
    button $loader.c.t.load -width 5 -text "Load" \
        -command "whiteboard.gallery_load $whiteboard_whiteboard($object)"

    button $loader.c.t.save -width 5 -text "Save" -command "destroy $loader" \
	-command "whiteboard.gallery_save $whiteboard_whiteboard($object)"

    frame $loader.c.b
    button $loader.c.b.delete -width 5 -text "Delete" \
	-command "whiteboard.gallery_remove $whiteboard_whiteboard($object)"

    button $loader.c.b.close -width 5 -text "Close" -command "destroy $loader"

    pack $loader.c.t.load -side left
    pack $loader.c.t.save -side right
    pack $loader.c.b.delete -side left
    pack $loader.c.b.close -side right

    pack $loader.c.t -side top -fill x
    pack $loader.c.b -side bottom -fill x

    pack $loader.f -fill x
    pack $loader.e -fill x
    pack $loader.c -fill x

    bind $loader.f.l <ButtonRelease-1> {
        set name [%W get @%x,%y]
        set wb [lindex [split %W "."] 1]
        set loader .$wb.load
        $loader.e delete 0 end
        $loader.e insert insert "$name"
    }

    bind $loader.f.l <Double-ButtonRelease-1> {
        set name [%W get @%x,%y]
        set wb [lindex [split %W "."] 1]
        set loader .$wb.load
        $loader.e delete 0 end
        $loader.e insert insert "$name"
	whiteboard.gallery_load .$wb
    }

    foreach l $lines {
	catch { unset foo }
	util.populate_array foo $l
	$loader.f.l insert end $foo(name)
    }
}

###
###

proc whiteboard.id_to_item id {
    global whiteboard_id
    set item ""
    foreach item [array names whiteboard_id] {
        if { $whiteboard_id($item) == $id } {
            break
        }
    }
    return $item
}

proc whiteboard.save {} {
}

proc whiteboard.get_gallery wb {
    set object [whiteboard.obj_from_dt $wb]
    io.outgoing "xmcp_gallery $object"
}

proc whiteboard.gallery_load wb {
    set object [whiteboard.obj_from_dt $wb]
    set what [$wb.load.e get]
    if { $what != "" } {
        io.outgoing "load \"$what\" in  $object"
    }
}

proc whiteboard.gallery_save wb {
    set object [whiteboard.obj_from_dt $wb]
    set what [$wb.load.e get]
    if { $what != "" } {
        io.outgoing "save $object as \"$what\""
    }
}

proc whiteboard.gallery_remove wb {
    set object [whiteboard.obj_from_dt $wb]
    set what [$wb.load.e get]
    if { $what != "" } {
        io.outgoing "remove \"$what\" from $object"
    }
}


proc whiteboard.refresh wb {
    set object [whiteboard.obj_from_dt $wb]
    io.outgoing "watch $object"
}

proc whiteboard.create title {
    if { ![util.use_native_menus] } {
	return [whiteboard.old.create $title]
    }
    global whiteboard_contrast whiteboard_colours tkmooLibrary \
        desktop_bitmap \
        whiteboard_width whiteboard_height whiteboard_margin \
        whiteboard_funky_bitmaps
    global image_data

    whiteboard.initialise

    set wb .[util.unique_id "wb"]

    toplevel $wb

    window.place_nice $wb

    $wb configure -bd 0 -highlightthickness 0

    wm title $wb "Whiteboard: $title"
    wm iconname $wb "$title"
    ###

    bind $wb <Destroy> "whiteboard.destroy $wb %W"

    ###
    frame $wb.draw -bd 0 -highlightthickness 0

	canvas $wb.draw.canvas \
		-scrollregion { 0 0 1000 800 } \
		-yscrollcommand "$wb.draw.vscroll set" \
		-xscrollcommand "$wb.draw.bottom.hscroll set" \
		-relief sunken -borderwidth 1 \
		-width 500 -height 300 \
		-highlightthickness 0 \
		-bg [colourdb.get lightblue]

        scrollbar $wb.draw.vscroll -command "$wb.draw.canvas yview" \
	    -highlightthickness 0
        window.set_scrollbar_look $wb.draw.vscroll

	frame $wb.draw.bottom \
	    -bd 0 -highlightthickness 0

	    frame $wb.draw.bottom.padding -height 8 -width 12 \
		-bd 0 -highlightthickness 0

        scrollbar $wb.draw.bottom.hscroll -command "$wb.draw.canvas xview" \
	    -highlightthickness 0 \
            -orient horizontal
        window.set_scrollbar_look $wb.draw.bottom.hscroll

        pack $wb.draw.bottom.padding \
	    -side right

	pack $wb.draw.bottom.hscroll \
	    -side left \
	    -fill x -expand 1

        pack $wb.draw.bottom -side bottom -fill x
        pack $wb.draw.vscroll -side right -fill y

	pack $wb.draw.canvas -fill both -expand 1
	bind $wb.draw.canvas <1>	        "whiteboard.pen-down $wb %x %y"
	bind $wb.draw.canvas <B1-Motion>        "whiteboard.pen-drag $wb %x %y"
	bind $wb.draw.canvas <B1-ButtonRelease> "whiteboard.pen-up   $wb %x %y"
	bind $wb.draw.canvas <3>		"whiteboard.delete   $wb %x %y"


	###
	menu $wb.control -tearoff 0 -relief raised -bd 1
	$wb configure -menu $wb.control


	$wb.control add cascade \
	    -label "File" \
	    -underline 0 \
	    -menu $wb.control.file

	menu $wb.control.file
	$wb.control.file add command \
	    -label "Gallery" \
	    -underline 0 \
	    -command "whiteboard.get_gallery $wb"
	window.hidemargin $wb.control.file

	$wb.control.file add command \
	    -label "Quit" \
	    -underline 0 \
	    -command "destroy $wb"
	window.hidemargin $wb.control.file

	$wb.control add cascade \
	    -label "Edit" \
	    -underline 0 \
	    -menu $wb.control.edit

	menu $wb.control.edit
	$wb.control.edit add command \
	    -label "Cut" \
	    -command "whiteboard.clean $wb"
	window.hidemargin $wb.control.edit
	$wb.control.edit add command \
	    -label "Copy" \
	    -command "whiteboard.clean $wb"
	window.hidemargin $wb.control.edit
	$wb.control.edit add command \
	    -label "Paste" \
	    -command "whiteboard.clean $wb"
	window.hidemargin $wb.control.edit
	$wb.control.edit add separator
	$wb.control.edit add command \
	    -label "Clear" \
	    -command "whiteboard.clean $wb"
	window.hidemargin $wb.control.edit
	$wb.control.edit add command \
	    -label "Refresh" \
	    -command "whiteboard.refresh $wb"
	window.hidemargin $wb.control.edit

	$wb.control.edit entryconfigure "Cut" -state disabled
	$wb.control.edit entryconfigure "Paste" -state disabled
	$wb.control.edit entryconfigure "Copy" -state disabled

	$wb.control add cascade \
            -label "Pen" \
            -underline 0 \
            -menu $wb.control.pen

        menu $wb.control.pen
        foreach pen { line rectangle oval arrow text move } {
	    set i [image create bitmap bitmap_$pen -data $image_data($whiteboard_funky_bitmaps($pen))]
            $wb.control.pen add command \
		-image $i \
                -underline 0 \
                -command "whiteboard.set_pen $wb $pen"
	    window.hidemargin $wb.control.pen
	}

	$wb.control add cascade \
            -label "Colour" \
            -underline 0 \
            -menu $wb.control.colour

	menu $wb.control.colour

	foreach colour $whiteboard_colours {
	    $wb.control.colour add command \
	        -label   "$colour" \
	        -underline 0 \
	        -background [colourdb.get $colour] \
	        -foreground [colourdb.get $whiteboard_contrast($colour)] \
	        -command "whiteboard.set_colour $wb $colour"
	    window.hidemargin $wb.control.colour
	}

	###

	whiteboard.set_colour $wb black
	whiteboard.set_pen $wb line



	###

	pack $wb.draw -side bottom -expand yes -fill both

        after idle "whiteboard.padding_resize $wb"

	return $wb
}

proc whiteboard.padding_resize whiteboard {
    if { [winfo exists $whiteboard] == 1 } {
        set internal [$whiteboard.draw.vscroll cget -width]
        set external [$whiteboard.draw.vscroll cget -bd]
        set full [expr $internal + 2*$external]
        $whiteboard.draw.bottom.padding configure -width $full -height $full
    }
}

proc whiteboard.old.create title {
    global whiteboard_contrast whiteboard_colours tkmooLibrary \
        desktop_bitmap \
        whiteboard_width whiteboard_height whiteboard_margin \
        whiteboard_funky_bitmaps
    global image_data

    whiteboard.initialise

    set wb .[util.unique_id "wb"]

    toplevel $wb

    window.place_nice $wb

    $wb configure -bd 0

    wm title $wb "Whiteboard: $title"
    wm iconname $wb "$title"
    ###

    bind $wb <Destroy> "whiteboard.destroy $wb %W"

    ###
    frame $wb.draw

	canvas $wb.draw.canvas \
		-scrollregion { 0 0 1000 800 } \
		-yscrollcommand "$wb.draw.vscroll set" \
		-xscrollcommand "$wb.draw.bottom.hscroll set" \
		-relief sunken -borderwidth 2 \
		-width 500 -height 300 \
		-highlightthickness 0 \
		-bg [colourdb.get lightblue]

        scrollbar $wb.draw.vscroll -command "$wb.draw.canvas yview" \
	    -highlightthickness 0
        window.set_scrollbar_look $wb.draw.vscroll

	frame $wb.draw.bottom
	    frame $wb.draw.bottom.padding -height 14 -width 14

        scrollbar $wb.draw.bottom.hscroll -command "$wb.draw.canvas xview" \
	    -highlightthickness 0 \
            -orient horizontal
        window.set_scrollbar_look $wb.draw.bottom.hscroll

        pack $wb.draw.bottom.padding -side right
	pack $wb.draw.bottom.hscroll -side left -fill x -expand 1

        pack $wb.draw.bottom -side bottom -fill x

        pack $wb.draw.vscroll -side right -fill y

	pack $wb.draw.canvas -fill both -expand 1
	bind $wb.draw.canvas <1>	        "whiteboard.pen-down $wb %x %y"
	bind $wb.draw.canvas <B1-Motion>        "whiteboard.pen-drag $wb %x %y"
	bind $wb.draw.canvas <B1-ButtonRelease> "whiteboard.pen-up   $wb %x %y"
	bind $wb.draw.canvas <3>		"whiteboard.delete   $wb %x %y"


	###
	frame $wb.control


	menubutton $wb.control.file \
	    -text "File" \
	    -underline 0 \
	    -menu $wb.control.file.m

	menu $wb.control.file.m
	$wb.control.file.m add command \
	    -label "Gallery" \
	    -underline 0 \
	    -command "whiteboard.get_gallery $wb"
	window.hidemargin $wb.control.file.m
	$wb.control.file.m add command \
	    -label "Quit" \
	    -underline 0 \
	    -command "destroy $wb"
	window.hidemargin $wb.control.file.m

	menubutton $wb.control.edit \
	    -text "Edit" \
	    -underline 0 \
	    -menu $wb.control.edit.m

	menu $wb.control.edit.m
	$wb.control.edit.m add command \
	    -label "Cut" \
	    -command "whiteboard.clean $wb"
	window.hidemargin $wb.control.edit.m
	$wb.control.edit.m add command \
	    -label "Copy" \
	    -command "whiteboard.clean $wb"
	window.hidemargin $wb.control.edit.m
	$wb.control.edit.m add command \
	    -label "Paste" \
	    -command "whiteboard.clean $wb"
	window.hidemargin $wb.control.edit.m
	$wb.control.edit.m add separator
	$wb.control.edit.m add command \
	    -label "Clear" \
	    -command "whiteboard.clean $wb"
	window.hidemargin $wb.control.edit.m
	$wb.control.edit.m add command \
	    -label "Refresh" \
	    -command "whiteboard.refresh $wb"
	window.hidemargin $wb.control.edit.m

	$wb.control.edit.m entryconfigure "Cut" -state disabled
	$wb.control.edit.m entryconfigure "Paste" -state disabled
	$wb.control.edit.m entryconfigure "Copy" -state disabled

	menubutton $wb.control.pen \
		-text "Pen" \
		-underline 0 \
		-menu $wb.control.pen.menu

        menu $wb.control.pen.menu
        foreach pen { line rectangle oval arrow text move } {
	    set i [image create bitmap bitmap_$pen -data $image_data($whiteboard_funky_bitmaps($pen))]
            $wb.control.pen.menu add command \
		-image $i \
                -underline 0 \
                -command "whiteboard.set_pen $wb $pen"
	    window.hidemargin $wb.control.pen.menu
	}

	menubutton $wb.control.colour \
		-text "Colour" \
		-underline 0 \
		-menu $wb.control.colour.menu

	menu $wb.control.colour.menu

	foreach colour $whiteboard_colours {
	    $wb.control.colour.menu add command \
	        -label   "$colour" \
	        -underline 0 \
	        -background [colourdb.get $colour] \
	        -foreground [colourdb.get $whiteboard_contrast($colour)] \
	        -command "whiteboard.set_colour $wb $colour"
	    window.hidemargin $wb.control.colour.menu
	}


	###
	frame $wb.control.indicator
	label $wb.control.indicator.pen -anchor center -text "pen"
	pack $wb.control.indicator.pen

	whiteboard.set_colour $wb black
	whiteboard.set_pen $wb line

	pack append $wb.control \
		$wb.control.file left \
		$wb.control.edit left \
		$wb.control.pen left \
		$wb.control.colour left

	pack $wb.control.indicator -fill x


	###

	pack $wb.control -side top -fill x
	pack $wb.draw -side bottom -expand yes -fill both

	return $wb
}

proc whiteboard.clean wb {
    set object [whiteboard.obj_from_dt $wb]
    whiteboard.CSclean $object
}

proc whiteboard.set_colour { wb colour } {
    global whiteboard_colour whiteboard_contrast
    set whiteboard_colour $colour
    $wb.control.colour configure \
	-background [colourdb.get $colour] \
        -foreground [colourdb.get $whiteboard_contrast($colour)]
}

proc whiteboard.set_pen { wb pen } {
    global whiteboard_pen whiteboard_funky_bitmaps tkmooLibrary
    set whiteboard_pen $pen
    return 
    $wb.control.indicator.pen configure \
	-bitmap @[file join $tkmooLibrary images $whiteboard_funky_bitmaps($pen)]
}

proc whiteboard.destroy { dt win } {
    global whiteboard_whiteboard whiteboard_id


    catch {
        foreach item [array names whiteboard_id] {
            unset whiteboard_id($item)
        }
    }

    catch {
	set object [whiteboard.obj_from_dt $dt]
	unset whiteboard_whiteboard($object)
	whiteboard.CSignore $object
    }
}


###
###

proc whiteboard.pen-down { dt x y } {
    global whiteboard_x1 whiteboard_y1 \
        whiteboard_funky \
        whiteboard_x2 whiteboard_y2 \
        whiteboard_pen whiteboard_item_to_move

    set cx [expr int([$dt.draw.canvas canvasx $x])]
    set cy [expr int([$dt.draw.canvas canvasy $y])]

    if { $whiteboard_funky } {
        set x $cx
        set y $cy
    }

    set whiteboard_x1 $x
    set whiteboard_y1 $y
    set whiteboard_x2 $x
    set whiteboard_y2 $y

    if { $whiteboard_pen == "move" } {
        set item [$dt.draw.canvas find withtag current]
        if { $item != "" } {
            set whiteboard_item_to_move $item
            whiteboard.clone $dt $item
        }
    }
}

###
proc whiteboard.bounds_check { a maxa margin } {
    return $a

    if { $a < $margin } { return $margin }
    if { $a > [set foo [expr $maxa - $margin]] } { return $foo }
    return $a
}

proc whiteboard.pen-drag { dt x y } {
    global whiteboard_x1 whiteboard_y1 whiteboard_x2 whiteboard_y2 \
        whiteboard_funky \
        whiteboard_pen whiteboard_item_to_move \
        whiteboard_width whiteboard_height whiteboard_margin

    set cx [expr int([$dt.draw.canvas canvasx $x])]
    set cy [expr int([$dt.draw.canvas canvasy $y])]

    if { $whiteboard_funky } {
        set x $cx
        set y $cy
    }

    set x [whiteboard.bounds_check $x $whiteboard_width $whiteboard_margin]
    set y [whiteboard.bounds_check $y $whiteboard_height $whiteboard_margin]

    set whiteboard_x2 $x
    set whiteboard_y2 $y


    $dt.draw.canvas delete ghost

    switch $whiteboard_pen {
	text {
            #do nothing
	}
	move {
            if { $whiteboard_item_to_move == "" } { return };

            set clone [whiteboard.clone $dt $whiteboard_item_to_move]
            set dx [expr $whiteboard_x2 - $whiteboard_x1]
            set dy [expr $whiteboard_y2 - $whiteboard_y1]
            $dt.draw.canvas move $clone $dx $dy
	}
	arrow {
            $dt.draw.canvas create line \
            $whiteboard_x1 $whiteboard_y1 \
            $whiteboard_x2 $whiteboard_y2 -tag ghost -arrow last
	}
	default {
            $dt.draw.canvas create $whiteboard_pen \
            $whiteboard_x1 $whiteboard_y1 \
            $whiteboard_x2 $whiteboard_y2 -tag ghost 
	}
    }
}

proc whiteboard.pen-up { dt x y } {
    global whiteboard_x1 whiteboard_y1 whiteboard_x2 whiteboard_y2 \
        whiteboard_funky \
        whiteboard_colour whiteboard_pen \
        whiteboard_item_to_move whiteboard_id \
        whiteboard_width whiteboard_height whiteboard_margin

    set cx [expr int([$dt.draw.canvas canvasx $x])]
    set cy [expr int([$dt.draw.canvas canvasy $y])]

    if { $whiteboard_funky } {
        set x $cx
        set y $cy
    }

    $dt.draw.canvas delete ghost

    set x [whiteboard.bounds_check $x $whiteboard_width $whiteboard_margin]
    set y [whiteboard.bounds_check $y $whiteboard_height $whiteboard_margin]

    set whiteboard_x2 $x
    set whiteboard_y2 $y

    set object [whiteboard.obj_from_dt $dt]

    if { $whiteboard_pen == "text" } {
        whiteboard.get_text $object $whiteboard_colour \
            $whiteboard_pen $whiteboard_x1 $whiteboard_y1
    } elseif { $whiteboard_pen == "move" } {
        if { $whiteboard_item_to_move == "" } { 
	    return 
	}
        set dx [expr $whiteboard_x2 - $whiteboard_x1]
        set dy [expr $whiteboard_y2 - $whiteboard_y1]
        whiteboard.CSmove $object $whiteboard_id($whiteboard_item_to_move) \
	    $dx $dy
    } {
        whiteboard.CSdraw_not_text $object $whiteboard_colour \
            $whiteboard_pen \
            $whiteboard_x1 $whiteboard_y1 \
            $whiteboard_x2 $whiteboard_y2
    }
    set whiteboard_item_to_move ""
}


proc whiteboard.get_text { object colour pen x1 y1 } {
    global whiteboard_scratch

    set win .wb_g_t

    catch { destroy $win };

    toplevel $win

    window.place_nice $win

    $win configure -bd 0

	wm title $win "Enter text"
	wm iconname $win "Enter Text"

    frame $win.entries
    label $win.entries.t -text "Text:"
	text $win.entries.text \
	    -highlightthickness 0 \
	    -width 40 \
	    -height 5 \
	    -font [fonts.get fixedwidth] \
	    -background [colourdb.get pink]

    focus $win.entries.text

    pack $win.entries.t    -side left
    pack $win.entries.text -side left

    ###
    set whiteboard_scratch($win:object) $object
    set whiteboard_scratch($win:colour) $colour
    set whiteboard_scratch($win:pen) $pen
    set whiteboard_scratch($win:x1) $x1
    set whiteboard_scratch($win:y1) $y1

    ###

    button $win.connect -text "Ok" \
        -command { 
	whiteboard.set_text 
	whiteboard.destroy_text
	}

    button $win.cancel -text "Cancel" -command "whiteboard.destroy_text"

    pack $win.entries
    pack $win.connect -side left
    pack $win.cancel -side right
}

proc whiteboard.destroy_text {} {
    global whiteboard_scratch
    set win .wb_g_t
    unset whiteboard_scratch
    destroy $win
}

proc whiteboard.set_text {} {
    global whiteboard_scratch
    set win .wb_g_t

    set object $whiteboard_scratch($win:object) 
    set colour $whiteboard_scratch($win:colour)
    set pen    $whiteboard_scratch($win:pen)
    set x1     $whiteboard_scratch($win:x1)
    set y1     $whiteboard_scratch($win:y1)

        set text [$win.entries.text get 1.0 end]
        regsub -all "\n" $text "\\\\\\n" text

    whiteboard.CSdraw_yes_text \
	$object $colour $pen $x1 $y1 "$text"
}

proc whiteboard.obj_from_dt dt {
    global whiteboard_whiteboard
    set object ""
    foreach object [array names whiteboard_whiteboard] {
        if { $whiteboard_whiteboard($object) == $dt } {
            break
        }
    }       
    return $object
}

proc whiteboard.delete { dt x y } {
    global whiteboard_id 
    set item [$dt.draw.canvas find withtag current]

    if { $item == "" } {
        return
    }
    set object [whiteboard.obj_from_dt $dt]
    whiteboard.CSdelete $object $whiteboard_id($item)
}


proc whiteboard.clone { dt id } {
    set type [$dt.draw.canvas type $id]
    set coords [$dt.draw.canvas coords $id]
    set x1 [lindex $coords 0]
    set y1 [lindex $coords 1]
    set x2 [lindex $coords 2]
    set y2 [lindex $coords 3]
    set clone ""
    switch $type {
        arrow {
            set clone [$dt.draw.canvas create line $x1 $y1 $x2 $y2 \
                -fill "red" -tag ghost -arrow last]
        }
        line {
            set clone [$dt.draw.canvas create line $x1 $y1 $x2 $y2 \
                -fill "red" -tag ghost]
        }
        rectangle {
            set clone [$dt.draw.canvas create rectangle $x1 $y1 $x2 $y2 \
                -outline "red" -tag ghost]
        }
        oval {
            set clone [$dt.draw.canvas create oval $x1 $y1 $x2 $y2 \
                -outline "red" -tag ghost]
        }
        text {
            set text [$dt.draw.canvas itemcget $id -text]
            set clone [$dt.draw.canvas create text $x1 $y1 -text $text \
                -fill "red" -tag ghost]
        }
        default {
            puts "Unknown type $type"
        }
    }
    return $clone
}
#
#

proc xmcp11.do_whiteboard-gallery* {} {
    if { [xmcp11.authenticated] == 1 } {
        request.set current xmcp11_multiline_procedure "whiteboard-gallery*"
    }
}

proc xmcp11.do_callback_whiteboard-gallery* {} {
    set which [request.current]
    set object [request.get $which object]
    set lines [request.get $which _lines]
    whiteboard.SCgallery $object $lines
}

proc xmcp11.do_whiteboard-show {} {
    if { [xmcp11.authenticated] != 1 } { return }

    set which [request.current]

    set name "no title"
    catch { set name [request.get $which name] }
    set object [request.get $which object]

    set whiteboard [whiteboard.SCshow $object $name]
    whiteboard.set_handler $whiteboard xmcp11
}

proc xmcp11.do_whiteboard-line {} {
    if { [xmcp11.authenticated] != 1 } { return }

    set which [request.current]
    set object [request.get $which object]
    set x1 [request.get $which x1]
    set y1 [request.get $which y1]
    set x2 [request.get $which x2]
    set y2 [request.get $which y2]
    set colour [request.get $which colour]

    whiteboard.SCline $object \
        $x1 $y1 \
        $x2 $y2 $colour
}

proc xmcp11.do_whiteboard-delete {} {
    if { [xmcp11.authenticated] != 1 } { return }

    set which [request.current]
    set object [request.get $which object]
    set id [request.get $which id]

    whiteboard.SCdelete $object $id
}

proc xmcp11.do_whiteboard-move {} {
    if { [xmcp11.authenticated] != 1 } { return }

    set which [request.current]
    set object [request.get $which object]
    set id [request.get $which id]
    set dx [request.get $which dx]
    set dy [request.get $which dy]
	
    whiteboard.SCmove $object $id \
        $dx $dy
}

proc xmcp11.do_whiteboard-draw {} {
    if { [xmcp11.authenticated] != 1 } { return }

    set which [request.current]
    set text "UNDEFINED"
    catch { 
	set text [request.get $which text]
	regsub -all "\\\\n" $text "\n" text 
    }
    set x2 "UNDEFINED"
    set y2 "UNDEFINED"
    catch { set x2 [request.get $which x2] }
    catch { set y2 [request.get $which y2] }

    set object [request.get $which object]
    set x1 [request.get $which x1]
    set y1 [request.get $which y1]
    set colour [request.get $which colour]
    set pen [request.get $which pen]
    set id [request.get $which id]

    whiteboard.SCdraw $object \
        $x1 $y1 \
        $x2 $y2 \
        $colour $pen \
        $id $text
}

proc xmcp11.do_whiteboard-clean {} {
    if { [xmcp11.authenticated] != 1 } { return }

    set which [request.current]
    set object [request.get $which object]
    whiteboard.SCclean $object
}

###
#
proc whiteboard.CSignore { object } {
    io.outgoing "ignore $object"
}

proc whiteboard.CSmove { object id dx dy } {
    io.outgoing "move $id $dx $dy on $object"
}

proc whiteboard.CSdraw_not_text { object colour pen x1 y1 x2 y2 } {
    io.outgoing "draw $colour $pen $x1 $y1 $x2 $y2 on $object"
}

proc whiteboard.CSdraw_yes_text { object colour pen x1 y1 text } {
    io.outgoing "draw $colour $pen $x1 $y1 \"$text\" on $object"
}

proc whiteboard.CSdelete { object id } {
    io.outgoing "delete $id in $object"
}

proc whiteboard.CSclean { object } {
    io.outgoing "clean $object"
}
#
#

