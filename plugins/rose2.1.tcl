#
#    tkMOO
#    ~/.tkMOO-lite/plugins/rose2.1.tcl
#

# tkMOO-light is Copyright (c) Andrew Wilson 1994,1995,1996,1997,1998,1999.
#
#       All Rights Reserved
#
# Permission is hereby granted to use this software for private, academic
# and non-commercial use. No commercial or profitable use of this
# software may be made without the prior permission of the author.
#
# THIS SOFTWARE IS PROVIDED BY ANDREW WILSON ``AS IS'' AND ANY
# EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL ANDREW WILSON BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# TODO
# o    replace Leave/Enter with Motion (mouse-over) events for the
#    active area highlight
# o    target highlights shouldn't obscure the faces
#        land < highlights < faces
#    mmm, tricky, since the highlights on the edges should
#    obscure the edges, and the faces obscure the edges...
#    except for the front edge which obscures the faces...
#
# o    plenty of code speedups, move costly setup code to .start
# o     self is always present in 'location'.  don't print our
#    username in another room if we're obviously 'here' instead, regardless
#    of what the who information may say.

client.register rose2 client_connected
client.register rose2 client_disconnected
client.register rose2 start

preferences.register location {Special Forces} {
    { {directive UseRose2}
        {type boolean}
        {default Off}
        {display "Display visual"} }
    { {directive Rose2ButtonFont}
        {type font}
        {default "-*-times-medium-r-*-*-10-*-*-*-*-*-*-*"}
        {default_if_empty}
        {display "Visual font"} }
}

proc rose2.client_connected {} {
    set use [worlds.get_generic Off {} {} UseRose2]

    if { [string tolower $use] == "on" } {
        rose2.create
    rose2.no_data
    }
    return [modules.module_deferred]
}

proc rose2.client_disconnected {} {
    rose2.destroy
    return [modules.module_deferred]
}

proc rose2.destroy {} {
    set r .rose2
    if { [winfo exists $r] == 1 } {
        window.remove_toolbar $r
        destroy $r
    }
}

proc rose2.random {range} {
  global rose2_ran
  set rose2_ran [expr ($rose2_ran * 9301 + 49297) % 233280]
  set rv [expr int($range * ($rose2_ran / double(233280)))]
  return $rv
}

# use native random if available
global tcl_version
if { $tcl_version >= 8.0 } {
proc rose2.random range {
    return [expr int(rand() * $range)]
}
}

proc rose2.start {} {
    global rose2_Xoffset rose2_Yoffset rose2_point rose2_corners
    set rose2_Xoffset 25
    set rose2_Yoffset 0

    global rose2_ran
    set rose2_ran [pid]

    set p 0
    for {set y 0} {$y < 4} {incr y} {
        for {set x 0} {$x < 4} {incr x} {
        if { $x < 2 } {
            set rose2_point($p) "[expr $rose2_Xoffset + ($x * 50) - (8 * $y)] [expr $rose2_Yoffset + $y * 16]"
        } {
            set rose2_point($p) "[expr $rose2_Xoffset + ($x * 50) + (8 * $y)] [expr $rose2_Yoffset + $y * 16]"
        }
        incr p
        }
    }

    set rose2_image_data(face.small.open) {
    R0lGODlhBQAFAPIAANnZ2f//AAAAAP/XANudAP///wAAAAAAACH5BAEAAAAALAAAAAAFAAUA
    AAMNCLEqIySMGecggGiQAAA7
    }
    set rose2_image_data(face.small.closed) {
    R0lGODlhBQAFAKEAANnZ2f//AP/XANudACH5BAEAAAAALAAAAAAFAAUAAAIKRG6iEyrsBhgU
    FAA7
    }

    set rose2_image_data(face.large.open) {
    R0lGODlhCgAKAPIAANnZ2f//AAAAAP/XANudAP///wAAAAAAACH5BAEAAAAALAAAAAAKAAoA
    AAMgCBDcqs2tIMQYlRBWb97BJQ4aM15leKYnSSha/D6ypiQAOw==
    }
    set rose2_image_data(face.large.closed) {
    R0lGODlhCgAKAKEAANnZ2f//AP/XANudACH5BAEAAAAALAAAAAAKAAoAAAIbBIJplnohohwD
    yVnhFdTurl3gxg0GhZpLShkFADs=
    }

    foreach name [array names rose2_image_data] {
        image create photo $name -data $rose2_image_data($name) -palette 4/8/4
    }

    # where are the points on each room, numbered clockwise from
    # top left
    array set rose2_corners {
        nw    {0 1 5 4}
        n    {1 2 6 5}
        ne    {2 3 7 6}
        w    {4 5 9 8}
        x    {5 6 10 9}
        e    {6 7 11 10}
        sw    {8 9 13 12}
        s    {9 10 14 13}
        se    {10 11 15 14}
    }

    visual.register rose2 update_location
    visual.register rose2 update_topology
    visual.register rose2 update_users
    visual.register rose2 update_self

    window.menu_tools_add "Visual on/off" rose2.toggle_visual
}

proc rose2.toggle_visual {} {
    if { [winfo exists .rose2] } {
        rose2.destroy
    } {
        rose2.create
        rose2.no_data
    rose2.update_self
    }
}

proc rose2.redither {} {
    foreach image {
    face.small.open face.small.closed face.large.open face.large.closed
    } {
    $image redither
    }
}

proc rose2.room_details location {
    global rose2_details
    if { [info exists rose2_details($location)] } {
    # the value is cached, use it
        rose2.set_text $rose2_details($location)
    return
    }
    if { ($location == "") } {
    rose2.set_text ""
    return
    }
    set topology [visual.get_topology $location 1]
    if { ($topology == {}) } {
    rose2.set_text ""
    return
    }

    set room_record [util.assoc $topology $location]
    set room_name [lindex $room_record 1]

    set text [string toupper $room_name]

    set users [visual.get_users]
    if { ($users == {}) } {
    rose2.set_text $text
    return
    }

    set people_here {}
    foreach user $users {
    if { [lindex $user 2] == $location } {
        lappend people_here $user
    }
    }

    set very_idle_time 9999999

    if { $people_here != {} } {
    append text ": "

    # make our name appear at the end of any idle-time sorted list
    # we do this by replacing our own idle time with a VERY big one
    # sure there are faster ways to do this...
    set self [visual.get_self]
    if { $self != "" } {
        # damn, should be a utils.iassoc...
        for {set i 0} {$i < [llength $people_here]} {incr i} {
        set record [lindex $people_here $i]
        if { [lindex $record 0] == $self } {
            set record [lreplace $record 3 3 $very_idle_time]
            set people_here [lreplace $people_here $i $i $record]
            break
        }
        }
    }

        set sorted [lsort -command rose2.sort_by_idle $people_here]

        foreach user $sorted {
        lappend names [lindex $user 1]
        }

        append text [join $names ", "]
    }
    rose2.set_text $text
    # set the cached value
    set rose2_details($location) $text
}

proc rose2.sort_by_idle {a b} {
    return [expr [lindex $a 3] - [lindex $b 3]]
}

# pass only those {direction roomid} pairs where (direction in okdirections)
proc rose2.filter_exits {okdirections exits} {
    set tmp {}
    foreach exit $exits {
    if { [lsearch -exact $okdirections [lindex $exit 0]] != -1 } {
        lappend tmp $exit
    }
    }
    return $tmp
}

proc rose2.update_topology {} { rose2.update_location }
proc rose2.update_users {} { rose2.update_location }
proc rose2.update_self {} { rose2.update_location }

proc rose2.init_details {} {
    global rose2_details
    catch { unset rose2_details }
}

proc rose2.update_location {} {
    # check that the widget is being displayed.  it's enough to
    # just check the per-world directive...

    if { [winfo exists .rose2] == 0 } {
    return
    }

    set location [visual.get_location]
    if { ($location == "") } {
    return
    }
    set topology [visual.get_topology $location 1]
    if { ($topology == {}) } {
    return
    }
    set users [visual.get_users]
    if { ($users == {}) } {
    # visual doesn't have that information yet, wait for it to
    # turn up, one or other of our handlers will be called shortly
    # afterwards, so we get another go at doing stuff.
    return
    }

    rose2.got_data
    rose2.redither

    # which cardinal points are visible from this location (x == here)
    set room_info [util.assoc $topology $location]
    set exits [lindex $room_info 2]
    set safe_exits [rose2.filter_exits {"n" "s" "e" "w" "ne" "nw" "se" "sw" "x"} $exits]

    set rooms [util.slice $safe_exits 0]

    # the current location is direction 'x'  (x marks the spot)
    lappend rooms x

    rose2.display $rooms

    # need to filter out exits that map to the same room.  we just
    # keep one of them

    # build a hash, keyed on exit destination
    foreach exit $safe_exits {
    set foo([lindex $exit 1]) $exit
    }

    # recompose from the list of de-duplicated destinations
    set safe_exits {}
    foreach room [array names foo] {
        lappend safe_exits $foo($room)
    }

    # add the 'x' room, our current location
    rose2.populate [concat $safe_exits [list [list x $location]]] $users
    # new information so clear any cached data
    rose2.init_details
    rose2.room_details $location
}

proc rose2.set_text text {
    set r .rose2
    $r.t configure -state normal
    $r.t delete 1.0 end
    $r.t insert insert $text paragraph_format
    $r.t configure -state disabled
}

proc rose2.create {} {
    set r .rose2
    frame $r
    canvas $r.c -height 50 -width 200 -bg lightgreen -highlightthickness 0 -bd 0
    pack $r.c -side left

    set rose_font [worlds.get_generic "" {} {} Rose2ButtonFont]

    text $r.t -height 4 -width 30 -font $rose_font \
    -highlightthickness 0 \
    -relief flat -bg [$r cget -bg] \
    -wrap word -cursor {}

    $r.t tag configure paragraph_format -lmargin2 4

    $r.t configure -state disabled

    pack $r.t -side right

    window.add_toolbar $r
    window.repack

    rose2.make_target nw 0 1 5 4
    rose2.make_target n 1 2 6 5
    rose2.make_target ne 2 3 7 6

    rose2.make_target w 4 5 9 8
    rose2.make_target x 5 6 10 9
    rose2.make_target e 6 7 11 10

    rose2.make_target sw 8 9 13 12
    rose2.make_target s 9 10 14 13
    rose2.make_target se 10 11 15 14

    # left hand edge
    global rose2_point
    set green_colour [$r.c cget -bg]
    set grey_colour [$r cget -bg]

    set dark_green [tkDarken $green_colour 70]
    set light_green [tkDarken $green_colour 130]

    eval $r.c create polygon -10 -10 $rose2_point(0) $rose2_point(12) -10 100 -tags BORDER -fill $grey_colour -outline $grey_colour
    eval $r.c create polygon 200 -10 $rose2_point(3) $rose2_point(15) 200 100 -tags BORDER -fill $grey_colour -outline $grey_colour

    # still needs another border rectangle behind
    # ...
    set p0x [lindex $rose2_point(0) 0]
    set p0y [lindex $rose2_point(0) 1]
    set p3x [lindex $rose2_point(3) 0]
    set p3y [lindex $rose2_point(3) 1]

    eval $r.c create polygon [expr $p0x - 100] -100 [expr $p3x + 100] -100 [expr $p3x + 100] $p0y [expr $p0x - 100] $p0y -fill $grey_colour -tags BORDER

    # and one in the foreground
    set p12x [lindex $rose2_point(12) 0]
    set p12y [lindex $rose2_point(12) 1]
    set p15x [lindex $rose2_point(15) 0]
    set p15y [lindex $rose2_point(15) 1]

    eval $r.c create polygon [expr $p12x - 100] $p12y [expr $p15x + 100] $p15y [expr $p15x + 100] +100 [expr $p12x - 100] +100 -fill $grey_colour -tags BORDER:FOREGROUND

    # the 3d look...
    eval $r.c create line $rose2_point(12) $rose2_point(0) $rose2_point(3) -fill $dark_green -tags \"BORDER DG3D\"

    eval $r.c create line $rose2_point(3) $rose2_point(15) -fill $light_green -tags \"BORDER LG3D\"

    eval $r.c create line $rose2_point(15) $rose2_point(12) -fill $light_green -tags \"BORDER:FOREGROUND LG3D\"

    # We don't delete the LAND any more, create the spline off-screen
    # and subsequent calls will reconfigure the coordinates.
    $r.c create polygon \
        0 0 1 1 2 2 3 3 \
        -splinesteps 20 \
        -stipple gray50 \
        -tags LAND \
        -smooth 1 -fill darkgreen

    rose2.depth_of_field
}

proc rose2.look_like colour {
    set r .rose2
    $r.c configure -bg $colour

    set dark_colour [tkDarken $colour 70]
    set light_colour [tkDarken $colour 130]

    $r.c itemconfigure DG3D -fill $dark_colour
    $r.c itemconfigure LG3D -fill $light_colour
}

proc rose2.no_data {} {
    rose2.look_like [. cget -bg]
}

proc rose2.got_data {} {
    rose2.look_like lightgreen
}

proc rose2.depth_of_field {} {
    set f .rose2
    $f.c lower LAND
    $f.c raise TARGET
    $f.c raise BORDER
    $f.c raise FACES:FAR
    $f.c raise FACES:MID
    $f.c raise FACES:NEAR
    $f.c raise BORDER:FOREGROUND
    $f.c raise SURFACE
}

proc rose2.make_target {direction p1 p2 p3 p4} {
    global rose2_point
    set r .rose2
    eval $r.c create polygon $rose2_point($p1) $rose2_point($p2) $rose2_point($p3) $rose2_point($p4) -smooth 1 -stipple gray50 -fill \"\" -tags \"TARGET TARGET:$direction\"
}

proc rose2.target {direction p1 p2 p3 p4} {
    global rose2_point
    set r .rose2
    if { $direction == "x" } { return }
    # a visible target, between the land and the smileys which we
    # can make transparent if we need to.
    # a transparent surface on top of everything
    set surface($direction) [eval $r.c create polygon $rose2_point($p1) $rose2_point($p2) $rose2_point($p3) $rose2_point($p4) -smooth 1 -fill \"\" -tags SURFACE]
    $r.c bind $surface($direction) <Enter> "$r.c itemconfigure TARGET:$direction -fill red; rose2.direction_details $direction"
    $r.c bind $surface($direction) <Leave> "$r.c itemconfigure TARGET:$direction -fill \"\"; rose2.direction_details x"
    $r.c bind $surface($direction) <Button1-ButtonRelease> "client.outgoing $direction"
}

proc rose2.direction_details direction {
    set location [visual.get_location]
    if { $location == "" } {
        return
    }
    if { $direction == "x" } {
    rose2.room_details $location
    } {
    set topology [visual.get_topology $location 1]
    if { $topology == {} } {
        return
    }
    set room [util.assoc $topology $location]
    set exits [lindex $room 2]
    if { $exits == {} } {
        return
    }
    set dexit [util.assoc $exits $direction]
    if { $dexit == {} } {
        return
    }
    set dlocation [lindex $dexit 1]
    rose2.room_details $dlocation
    }
}

# given a set of connected rooms, work out the spline points
# encompassing the set.
proc rose2.make_spline rooms {
    global rose2_corners

    # initialise an over-large map
    for {set y 0} {$y < 5} {incr y} {
        for {set x 0} {$x < 5} {incr x} {
        set map($x,$y) ""
        }
    }

    # work out where the named rooms are in the map

    array set map_xy {
        1,1 nw
        2,1 n
        3,1 ne
        1,2 w
        2,2 x
        3,2 e
        1,3 sw
        2,3 s
        3,3 se
    }

    # invert the array for fast lookups
    foreach xy [array names map_xy] {
    set xy_map($map_xy($xy)) $xy
    }

    # mark the named rooms on the map
    foreach room $rooms {
    set map($xy_map($room)) 1
    }

    # find the top-most named room
    set top ""
    for {set y 0} {$y < 5} {incr y} {
        for {set x 0} {$x < 5} {incr x} {
        if { ($top == "") && ($map($x,$y) != "") } {
        set top $map_xy($x,$y)
        }
        }
    }

    # start above the top room
    set X [lindex [split $xy_map($top) ","] 0]
    set Y [lindex [split $xy_map($top) ","] 1]
    incr Y -1

    # which way are we going?
    set FACE e

    # if we move how much do we move by?
    set dx(n) 0
    set dy(n) -1
    set dx(e) 1
    set dy(e) 0
    set dx(s) 0
    set dy(s) 1
    set dx(w) -1
    set dy(w) 0

    # if we turn where are we facing?
    # new = turn(old,direction)

    array set turn {
        n,right    e
        e,right    s
        s,right    w
        w,right    n
        n,left    w
        e,left    n
        s,left    e
        w,left    s
    }

    # what do we add to our present position to get the right hand
    # position, depends which way we're facing
    set right_x(n) 1
    set right_y(n) 0
    set right_x(e) 0
    set right_y(e) 1
    set right_x(s) -1
    set right_y(s) 0
    set right_x(w) 0
    set right_y(w) -1

    set STARTX $X
    set STARTY $Y
    set first_time 1

    # roll round the maze
    while { ("$STARTX,$STARTY" != "$X,$Y") || ($first_time == 1) } {
    set first_time 0

    # take a mark on the room to our right
    set new_right_x [expr $X + $right_x($FACE)]
    set new_right_y [expr $Y + $right_y($FACE)]
    lappend MARKS [rose2.mark $FACE $rose2_corners($map_xy($new_right_x,$new_right_y))]

    # proceed if possible
    set my_ahead_x [expr $X + $dx($FACE)]
    set my_ahead_y [expr $Y + $dy($FACE)]

    if { $map($my_ahead_x,$my_ahead_y) == "" } {
        set X $my_ahead_x
        set Y $my_ahead_y
    } {
        # turn 90 anticlockwise
        set FACE $turn($FACE,left)
    }

    set my_right_x [expr $X + $right_x($FACE)]
    set my_right_y [expr $Y + $right_y($FACE)]
    # anyone on our right?
    if { $map($my_right_x,$my_right_y) == "" } {

        # turn 90 clockwise
        set FACE $turn($FACE,right)
        # move
        incr X $dx($FACE)
        incr Y $dy($FACE)

    }
    }

    # remove duplicate consecutive points and return a flat list
    set tmp [eval concat $MARKS]
    #remove consecutive duplicates
    set last ""
    while { $tmp != {} } {
    if { [lindex $tmp 0] != $last } {
        lappend tmp2 [lindex $tmp 0]
        set last [lindex $tmp 0]
    }
    set tmp [lrange $tmp 1 end]
    }

    # clean up, drop the last element, which is the same as the first
    return [lrange $tmp2 0 [expr [llength $tmp2] - 2]]
}

proc rose2.mark { face points } {
    if { $face == "n" } {
    return [list [lindex $points 3] [lindex $points 0]]
    }
    if { $face == "e" } {
    return [list [lindex $points 0] [lindex $points 1]]
    }
    if { $face == "s" } {
    return [list [lindex $points 1] [lindex $points 2]]
    }
    if { $face == "w" } {
    return [list [lindex $points 2] [lindex $points 3]]
    }
}

proc rose2.make_coords points {
    global rose2_point
    foreach p $points {
    lappend tmp $rose2_point($p)
    }
    return [eval concat $tmp]
}

proc rose2.display rooms {
    global rose2_corners
    set coords [rose2.make_coords [rose2.make_spline $rooms]]

    set r .rose2

    $r.c delete SURFACE

    # update the spline's coordinates
    eval $r.c coords LAND $coords

    # clear any targets
    $r.c itemconfigure TARGET -fill ""

    foreach room $rooms {
        eval rose2.target $room $rose2_corners($room)
    }

    rose2.depth_of_field
}

# rooms = { {direction roomid} ... } including 'x'
# users = { normal users list ... }
proc rose2.populate { rooms users } {
    # delete current smileys
    set f .rose2
    $f.c delete FACES:FAR FACES:MID FACES:NEAR

    # how many people in each room?  initialise all possible rooms to 0
    foreach room $rooms { set count([lindex $room 1]) 0 }
    foreach user $users { set count([lindex $user 2]) 0 }
    foreach user $users { incr count([lindex $user 2]) }

    # how many people active in each room?
    foreach room $rooms { set active([lindex $room 1]) 0 }
    foreach user $users { set active([lindex $user 2]) 0 }
    foreach user $users {
    # active if idle for < 1 minute
    if { [lindex $user 3] < 60 } {
        incr active([lindex $user 2])
    }
    }

    foreach room $rooms {
        set direction [lindex $room 0]
        set roomid [lindex $room 1]
        if { $count($roomid) > 0 } {
        # breaks if you call it with a value count=0
        rose2.people $direction $count($roomid) $active($roomid)
    }
    }

    # get the layering right
    rose2.depth_of_field
}

proc rose2.people { where count active } {
    global rose2_point

    # how many faces to draw
    set num 0
    if { $count > 0 } { set num 1 }
    if { $count > 2 } { set num 2 }
    if { $count > 5 } { set num 3 }

    # how many faces blink?
    set anum 0
    if { $active > 0 } { set anum 1 }
    if { $active > 2 } { set anum 2 }
    if { $active > 5 } { set anum 3 }

    # what size of face, depends on the room

    array set size {
        nw small
        n  small
        ne small
        w  large
        x  large
        e  large
        sw large
        s  large
        se large
    }

    # where to place the faces, randomly about a point for now
    # expensive setup costs here...
    foreach dir { nw n ne w x e sw s se } {
        set centre($dir) [rose2.centre $dir]
    }

    set f .rose2

    # tagging to ensure the faces in further rooms don't obscure
    # faces in nearer rooms.

    array set tags {
    nw    FACES:FAR
    n    FACES:FAR
    ne    FACES:FAR
    w    FACES:MID
    x    FACES:MID
    e    FACES:MID
    sw    FACES:NEAR
    s    FACES:NEAR
    se    FACES:NEAR
    }

    # draw the suckers, lowest on the screen first...
    for {set i 0} {$i < $num} {incr i} {
        set r [expr [rose2.random 30] - 15]
        set x [expr [lindex $centre($where) 0] + int($r)]
        set r [expr [rose2.random 15] - 10]
        set y [expr [lindex $centre($where) 1] + int($r)]
    lappend coords "$x $y"
    }

    # display them highest to lowest, so from the 'back' to the
    # 'front' of the display.  we need the blinkers to be at the
    # front though.

    # how many non blinkers are there?
    set diff [expr $num - $anum]

    foreach xy [lsort -command rose2.sort_by_y $coords] {
        eval set image \[$f.c create image $xy -image face.$size($where).open -tags $tags($where)\]
    if { $diff <= 0 } {
        set ropen [expr 3000 + [rose2.random 1000]]
        rose2.blink $image $size($where) $ropen 100
    }
    # one less non blinker to worry about
    incr diff -1
    }
}

proc rose2.sort_by_y { a b } {
    if { [lindex $a 1] > [lindex $b 1] } {
    return 1
    }
    return 0
}

proc rose2.centre where {
    global rose2_point rose2_corners

    set top_left [lindex $rose2_corners($where) 0]
    set top_right [lindex $rose2_corners($where) 1]
    set bottom_left [lindex $rose2_corners($where) 3]

    set tlx [lindex $rose2_point($top_left) 0]
    set tly [lindex $rose2_point($top_left) 1]
    set trx [lindex $rose2_point($top_right) 0]
    set bly [lindex $rose2_point($bottom_left) 1]

    set cx [expr $tlx + int(($trx - $tlx)/2)]
    set cy [expr $tly + int(($bly - $tly)/2)]

    return "$cx $cy"
}

proc rose2.blink_open {item size open close} {
    set f .rose2
    # is this item on the canvas?  If we close the widget (following
    # a disconnection say then the initial find will fail because $f.c
    # no longer exists... Cope.
    set images {}
    catch { set images [$f.c find all] }
    if { [lsearch -exact $images $item] != -1 } {
        $f.c itemconfigure $item -image face.$size.open
        after $open rose2.blink_closed $item $size $open $close
    }
}
proc rose2.blink_closed {item size open close} {
    set f .rose2
    # is this item on the canvas?  If we close the widget (following
    # a disconnection say then the initial find wil fail because $f.c
    # no longer exists... Cope.
    set images {}
    catch { set images [$f.c find all] }
    if { [lsearch -exact $images $item] != -1 } {
        $f.c itemconfigure $item -image face.$size.closed
        after $close rose2.blink_open $item $size $open $close
    }
}

proc rose2.blink {item size open close} {
    rose2.blink_open $item $size $open $close
}
