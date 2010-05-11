
client.register desktop start
proc desktop.start {} {
     global desktop_width desktop_height desktop_margin \
	 desktop_icon_width desktop_icon_height desktop_text_width \
	 desktop_data desktop_synthesise_callbacks

    set desktop_width	500
    set desktop_height	600
    set desktop_margin	10
    set desktop_icon_width	48
    set desktop_icon_height	48
    set desktop_text_width	100

    array set desktop_data "
        folder,bitmap 	dir.xbm
        note,bitmap 	text.xbm
        thing,bitmap 	burst.xbm
        player,bitmap 	person.xbm
        whiteboard,bitmap image2.xbm
        folder,fg 	[colourdb.get darkgreen]
        note,fg 	[colourdb.get blue]
        thing,fg 	[colourdb.get white]
        player,fg 	[colourdb.get red]
        whiteboard,fg 	[colourdb.get orange]
        folder,drag 	idir.xbm
        note,drag 	idaho.xbm
        thing,drag 	iburst.xbm
        player,drag 	iperson.xbm
        whiteboard,drag iimage2.xbm
    "

    set desktop_synthesise_callbacks 1
}

proc desktop.set_handler { desk handler } {
    global desktop_handler
    set desktop_handler($desk) $handler
}
proc desktop.get_handler desk {
    global desktop_handler
    return $desktop_handler($desk)
}

proc draganddrop.get { item property } {
    global draganddrop_data
    return $draganddrop_data($item:$property)
}

proc draganddrop.set { item property value } {
    global draganddrop_data
    set draganddrop_data($item:$property) $value
}

proc draganddrop.destroy item {
    global draganddrop_data
    foreach name [array names draganddrop_data "$item:*"] {
        unset draganddrop_data($name)
    }
}


proc desktop.create { title object type } {
    global tkmooLibrary \
        desktop_current desktop_data \
        desktop_width desktop_height desktop_item_callback

    set dt .[util.unique_id "dt"]

    toplevel $dt

    window.place_nice $dt

    $dt configure -bd 0 -highlightthickness 0

    wm title $dt $title
    wm iconname $dt $title

    bind $dt <Destroy> "desktop.destroy $dt"

    frame $dt.frame -bd 0 -highlightthickness 0

    set canvas $dt.frame.canvas

    canvas $canvas \
	-background [option get . desktopBackground DesktopBackground] \
	-relief flat \
        -bd 0 -highlightthickness 0 \
	-scrollregion { 0 0 500 800 } \
	-width 500 -height 300 \
	-yscrollcommand "$dt.frame.vscroll set" \
	-xscrollcommand "$dt.frame.bottom.hscroll set" 

    scrollbar $dt.frame.vscroll -command "$canvas yview" \
	-highlightthickness 0

    frame $dt.frame.bottom \
	-bd 0 -highlightthickness 0

    frame $dt.frame.bottom.padding

    scrollbar $dt.frame.bottom.hscroll -command "$canvas xview" \
	-highlightthickness 0 \
	-orient horizontal

	pack $dt.frame.bottom.padding -side right
	pack $dt.frame.bottom.hscroll -side left -fill x -expand 1

    pack $dt.frame.bottom -side bottom -fill x
    pack $dt.frame.vscroll -side right -fill y

    bind $canvas <2>		"$canvas scan mark %x %y"
    bind $canvas <B2-Motion>	"$canvas scan dragto %x %y"

    pack $canvas -expand yes -fill both
    pack $dt.frame -expand yes -fill both

    set desktop_current ""

    draganddrop.set $canvas drop 1	
    set desktop_item_callback($canvas:objid) $object

    set desktop_item_callback($canvas:Drop) "@move that to this"

    set desktop_item_callback($canvas:type) $type

    after idle "desktop.padding_resize $dt"

    return $dt
}

proc desktop.padding_resize desktop {
    if { [winfo exists $desktop] == 1 } {
        set internal [$desktop.frame.vscroll cget -width]
        set external [$desktop.frame.vscroll cget -bd]
        set full [expr $internal + 2*$external]
        $desktop.frame.bottom.padding configure -width $full -height $full
    }
}

proc desktop.garbage_collect_icons dt {
    global desktop_item_callback
    foreach name [array names desktop_item_callback] {
        catch {
            if { [regexp "^$dt.frame.canvas.(nt.*):objid" $name throwaway icon] == 1 } {
	        destroy $dt.frame.canvas.$icon
            }
        }
        if { [regexp "^$dt.frame.canvas\\..*" $name throwaway] == 1 } {
            unset desktop_item_callback($name)
        }
    }
}

proc desktop.garbage_collect_all dt {
    global desktop_item_callback
    foreach name [array names desktop_item_callback "$dt.frame.canvas*"] {
        unset desktop_item_callback($name)
    }
}

proc desktop.destroy dt {
    global desktop_desktop 

    draganddrop.destroy $dt
    foreach foo [array names desktop_desktop] {
        if { $desktop_desktop($foo) == $dt } {
            io.outgoing "remove $foo from desk"
            unset desktop_desktop($foo)
	    desktop.garbage_collect_all $dt
            break
        }
    }
}

proc desktop.item { type text x y obj dt eOne eThree eDrop eDropped ePick } {
    global tkmooLibrary \
        desktop_data \
	desktop_item_callback \
	desktop_icon_width desktop_icon_height desktop_text_width \
	image_data

    set new_tag [util.unique_id "nt"]

    set canvas $dt.frame.canvas
    set graphic $canvas.$new_tag

    canvas $graphic \
	-background [option get . desktopBackground DesktopBackground] \
	-width $desktop_icon_width -height $desktop_icon_height \
        -highlightthickness 0 


    bindtags $graphic $graphic

    bind $graphic <1>                       "desktop.itemPick $dt %x %y %X %Y"
    bind $graphic <B1-Motion>               "desktop.itemDrag $dt %x %y %X %Y"
    bind $graphic <B1-ButtonRelease>        "desktop.itemDrop $dt %x %y %X %Y"
    bind $graphic <Double-1>                "desktop.itemOpen $dt %x %y %X %Y" 
    bind $graphic <Double-B3-ButtonRelease> "desktop.itemOpen3 $dt %x %y %X %Y"

    set i [image create bitmap \
	-foreground $desktop_data($type,fg) \
	-data $image_data($desktop_data($type,bitmap))]
    $graphic create image \
	[expr int($desktop_icon_width/2)] [expr int($desktop_icon_height/2)] \
	-image $i \
	-tags "$new_tag object"


    set ex $x
    set wy [expr $y + 40]
    set nn [$canvas create window $ex $wy \
	        -window $graphic \
	        -anchor s]

    $canvas create text $x $wy -text $text \
        -tags "$new_tag" -width $desktop_text_width \
	-anchor n \
	-justify center \
        -font [fonts.plain]

    set desktop_item_callback($canvas:$nn) $graphic

    draganddrop.set $graphic drag 1

    if { $type == "folder" } {
	draganddrop.set $graphic drop 1
    }

    if { $eDrop != "-" } {
	draganddrop.set $graphic drop 1
    };

    if { $eDropped != "-" } {
	draganddrop.set $graphic dropped 1
    };

    set desktop_item_callback($graphic:Open1)   $eOne
    set desktop_item_callback($graphic:Open3)   $eThree
    set desktop_item_callback($graphic:Drop)    $eDrop
    set desktop_item_callback($graphic:Dropped) $eDropped
    set desktop_item_callback($graphic:Pick)    $ePick

    set desktop_item_callback($graphic:type)    $type

    set desktop_item_callback($graphic:objid) $obj

    return $graphic
}

###
proc desktop.item_callback { hook item dt } {
    global desktop_item_callback
    if { ! [info exists desktop_item_callback($dt.$item:$hook)]} {
        window.displayOutput "no $dt.$item:$hook\n" ""
        update
    }
    return $desktop_item_callback($dt.$item:$hook)
}

proc desktop.build_callback { text this that } {
    regsub -all -nocase {this} $text $this foo
    regsub -all -nocase {that} $foo $that callback
    return $callback
}


proc desktop.itemOpen {dt x y X Y} {
    global desktop_item_callback

    set where [winfo containing $X $Y]

    set cb "-"
    catch { set cb [desktop.get_callback $where Open1] }
    if { $cb != "-" } {
	set objid $desktop_item_callback($where:objid)
        set new_cb [desktop.build_callback $cb $objid THAT] 
        io.outgoing $new_cb
    }
}

proc desktop.itemOpen3 {dt x y X Y} {
    global desktop_item_callback

    set where [winfo containing $X $Y]

    set cb "-"
    catch { set cb [desktop.get_callback $where Open3] }
    if { $cb != "-" } {
        set objid $desktop_item_callback($where:objid)
    	set new_cb [desktop.build_callback $cb $objid THAT]
    	io.outgoing $new_cb
    }
}

proc desktop.itemPick {dt x y X Y} {
    global desktop_lastX desktop_lastY desktop_current \
	desktop_height desktop_width desktop_margin \
	tkmooLibrary desktop_item_callback desktop_dragging

    set desktop_dragging 0

    set where [winfo containing $X $Y]

    catch {
    if { [draganddrop.get $where drag] == 1 } {
        set desktop_current $where

        set cb "-"
        catch { set cb [desktop.get_callback $where Pick] }
        if { $cb != "-" } {
            set objid $desktop_item_callback($where:objid)
            set new_cb [desktop.build_callback $cb $objid THAT]
            io.outgoing $new_cb
        }
    }
    }
}



proc desktop.itemDrag {dt x y X Y} {
    global desktop_current \
	desktop_width   \
	desktop_item_callback desktop_data \
	desktop_dragging \
	tkmooLibrary 

    if { $desktop_current == "" } { return }

    if { $desktop_dragging == 0 } {
	set desktop_dragging 1
        set where $desktop_current
        $where configure -cursor icon
    }
}


proc desktop.itemDrop {dt x y X Y} {
    global desktop_current \
	desktop_dragging \
	desktop_item_callback

    set desktop_dragging 0

    if { $desktop_current == "" } { return }

    set where [winfo containing $X $Y]
    $desktop_current configure -cursor {}

    set check_list ""


    set can_dropped 0
    catch { set can_dropped [draganddrop.get $desktop_current dropped] }

    if { $can_dropped == 1 } {

        set cb "-"
        catch { set cb [desktop.get_callback $desktop_current Dropped] }

        if { $cb != "-" } {
            set iobjid $desktop_item_callback($desktop_current:objid)
            set dobjid $desktop_item_callback($where:objid)
            set new_cb [desktop.build_callback $cb $iobjid $dobjid]
            io.outgoing $new_cb

            ###
            set old_location ""
            if { [regexp {^(.*)\.nt} $desktop_current throwaway location] == 1 } {
                set old_location $desktop_item_callback($location:objid)
            }

	    set check_list "$check_list $dobjid $iobjid $old_location"
        }

    } {
    }


    set can_drop 0
    catch { set can_drop [draganddrop.get $where drop] }

    if { $can_drop == 1 } {

        set cb "-"
        catch {
            set cb [desktop.get_callback $where Drop]
            set iobjid $desktop_item_callback($where:objid)
            set dobjid $desktop_item_callback($desktop_current:objid)
        }

        if { $iobjid == $dobjid } {
        } {

            if { $cb != "-" } {
                set new_cb [desktop.build_callback $cb $iobjid $dobjid]
                io.outgoing $new_cb
        

                set old_location ""
                if { [regexp {^(.*)\.nt} $desktop_current throwaway location] == 1 } {
                    set old_location $desktop_item_callback($location:objid)
                }
        
	        set check_list "$check_list $dobjid $iobjid $old_location"
            }
	}

    } {
    }

    if { $check_list != "" } {
        io.outgoing "check $check_list on desk"
    }

    set desktop_current ""
}

###

proc desktop.SCremove { object } {
    global desktop_desktop
    catch { destroy $desktop_desktop($object) }
}

proc desktop.SCdesktop { name type object parent location lines } {
    global desktop_desktop desktop_item_callback

    if { [info exists desktop_desktop($object)] } {
        set dt $desktop_desktop($object)

        $dt.frame.canvas delete all
	draganddrop.destroy $dt.frame.canvas
	draganddrop.set $dt.frame.canvas drop 1
	desktop.garbage_collect_icons $dt
    } {
        set dt [desktop.create $name $object $type]
        set desktop_desktop($object) $dt
    }


    wm title $dt "Desktop: $name"

    set xxx -1
    set yyy -1
    
    foreach line $lines {
        set xxx [expr int( ($xxx + 1) % 5)]

        if { $xxx == 0 } {
            set yyy [expr int( ($yyy + 1) )]
        }

        set xcoord [expr $xxx * 100 + 50]
        set ycoord [expr $yyy * 100 + 20]


            catch {unset object_data}

        catch {unset object_data}

	array set object_data {
	    location	""
	    parent	""
	    type	""
	    name	""
	    1		-
	    drop	-
	    dropped	-
	    3		-
	    pick	-
	}

        util.populate_array object_data $line

        set object	$object_data(object)
        set name	$object_data(name)
        set type	$object_data(type)
        set xone	$object_data(1)
        set xdrop	$object_data(drop)
        set xdropped	$object_data(dropped)
        set xthree	$object_data(3)
        set xpick	$object_data(pick)

        switch $type {
            note {
                desktop.item "note" "$name" $xcoord $ycoord \
                    "$object" $dt $xone $xthree $xdrop $xdropped $xpick
            }
            player {
                desktop.item "player" "$name" $xcoord $ycoord \
                    "$object" $dt $xone $xthree $xdrop $xdropped $xpick
            }
            whiteboard {
                desktop.item "whiteboard" "$name" $xcoord $ycoord \
                    "$object" $dt $xone $xthree $xdrop $xdropped $xpick
            }
            folder {
                desktop.item "folder" "$name" $xcoord $ycoord \
                    "$object" $dt $xone $xthree $xdrop $xdropped $xpick
            }
            default {
                desktop.item "thing" "$name" $xcoord $ycoord \
                    "$object" $dt $xone $xthree $xdrop $xdropped $xpick
            }
        }
    }
    after idle "wm deiconify $dt; raise $dt"
    return $dt
}

proc desktop.synthesise_callback { type event } {
    array set callback {
	Open1	-
	Open3	-
	Drop	-
	Dropped	-
	Pick	-
    }
    switch $type {
        note {
            set callback(Open1) "read this"
            set callback(Open3) "@edit this"
        }
        player {
            set callback(Open1) "put this on desk"
            set callback(Drop) "@move that to this"
        }
        whiteboard { 
            set callback(Open1) "watch this"
            set callback(Open3) "ignore this"
        }
        folder {
            set callback(Open1) "put this on desk"
            set callback(Drop) "put that in this"
        }
        room {
            set callback(Open1) "put this on desk"
            set callback(Drop) "@move that to this"
        }
        thing {
        } 
        default {
	    puts "desktop.synthesise_callback: Unknown type '$type'"
        } 
    }
    return $callback($event)
}


proc desktop.get_callback { item event } {
    global desktop_item_callback desktop_synthesise_callbacks
    set type $desktop_item_callback($item:type)
    set callback [desktop.synthesise_callback $type $event]


    if { $desktop_synthesise_callbacks == 0 } {
        catch { set callback $desktop_item_callback($item:$event) }
    }
    return $callback
}
#
#

###
proc xmcp11.do_desktop-remove {} {
    if { [xmcp11.authenticated] == 1 } {
        desktop.SCremove [request.get current object]
    }
}

proc xmcp11.do_desktop* {} {
    if { [xmcp11.authenticated] == 1 } {
        request.set current xmcp11_multiline_procedure "desktop*"
    }
}

proc xmcp11.do_callback_desktop* {} {
    set which [request.current]
    set name     [request.get $which name]
    set type     [request.get $which type]
    set object   [request.get $which object]
    set parent   [request.get $which parent]
    set location [request.get $which location]
    set lines    [request.get $which _lines]

    set desktop [desktop.SCdesktop $name $type $object $parent \
        $location $lines]
    desktop.set_handler $desktop xmcp11
}
#
#

###
proc mcp.do_desktop-remove {} {
        if { [mcp.authenticated] == 1 } {
        	desktop.SCremove [request.get current object]
        }
}

proc mcp.do_desktop* {} {
	if { [mcp.authenticated] == 1 } {
		request.set current mcp_multiline_procedure "desktop*"
	}
}

proc mcp.do_callback_desktop* {} {
	set which [request.current]
	set name     [request.get $which name]
	set type     [request.get $which type]
	set object   [request.get $which object]
	set parent   [request.get $which parent]
	set location [request.get $which location]
	set lines    [request.get $which _lines]

	set desktop [desktop.SCdesktop $name $type $object $parent \
		$location $lines]
        desktop.set_handler $desktop mcp
}
#
#
