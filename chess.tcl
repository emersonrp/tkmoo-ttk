

client.register chess start
proc chess.start {} {
    global chess_bitmap

    array set chess_bitmap {
        K king.xbm
        k king.xbm
        Q queen.xbm
        q queen.xbm
        B bishop.xbm
        b bishop.xbm
        N knight.xbm
        n knight.xbm
        R rook.xbm
        r rook.xbm
        P pawn.xbm
        p pawn.xbm
    }
}

proc chess.SCboard { object board turn colour sequence } {
    global chess_board chess_sequence chess_turn
    if { [winfo exists .chessboard] != 1 } {
	chess.create
    }
    set chess_sequence $sequence
    set chess_turn $turn
    chess.display $board $colour
    set chess_board(.chessboard) $object
}

proc chess.display_piece { column row piece } {
    global chess_bitmap tkmooLibrary chess_pieces \
	image_data
    set b .chessboard
    set x [expr $column*32+16]
    set y [expr $row*32+16]

    if { [chess.piece_colour $piece] == "white" } {
	set colour "#ffa0a0"
    } {
	set colour "#a0a0ff"
    }



    set id [$b.c create image $x $y \
	-tags CHESS_PIECE \
	-image chess_$chess_bitmap($piece).[chess.piece_colour $piece]]


    set chess_pieces(id:$id) $piece
    set chess_pieces(xy:$id) [list [expr $column + 1] [expr $row + 1]]
}

proc chess.build_images {} {
    global chess_bitmap image_data
    foreach key [array names chess_bitmap] {
	set foo($chess_bitmap($key)) 1
    }
    foreach piece [array names foo] {
        image create bitmap "chess_$piece.white" \
            -foreground "#ffa0a0" \
            -data $image_data($piece)
        image create bitmap "chess_$piece.black" \
            -foreground "#a0a0ff" \
            -data $image_data($piece)
        image create bitmap "chess_$piece.ghost" \
            -foreground "#a0e0a0" \
            -data $image_data($piece)
        image create bitmap "chess_$piece.stationary_ghost" \
            -foreground "#c0c0c0" \
            -data $image_data($piece)
    }
}

proc chess.display { board colour } {
    global chess_piece chess_pieces chess_bitmap chess_my_colour \
	chess_turn

    set b .chessboard

    $b.c delete CHESS_PIECE
    catch { unset chess_pieces }
    set chess_piece ""

    set chess_my_colour $colour

    set places [split $board {}]

    if { $chess_my_colour == "black" } {
        for {set column 0} {$column < 8} {incr column} {
            for {set row 0} {$row < 8} {incr row} {
	        set piece [lindex $places 0]
	        set places [lrange $places 1 end]
	        if { $piece == "." } { continue }
	        chess.display_piece $column $row $piece
            }
        }
    } {
        for {set column 7} {$column >= 0} {set column [expr $column - 1]} {
            for {set row 7} {$row >= 0} {set row [expr $row - 1]} {
	        set piece [lindex $places 0]
	        set places [lrange $places 1 end]
	        if { $piece == "." } { continue }
	        chess.display_piece $column $row $piece
            }
        }
    }

    if { $chess_turn == 1 } {
	$b.l configure -text "It's your turn to move..."
    } {
	$b.l configure -text "It's your opponent's turn to move..."
    }
}


proc chess.create {} {
    global tkmooLibrary
    set b .chessboard

    toplevel $b

    window.place_nice $b

    $b configure -bd 0 -highlightthickness 0

    wm title $b "Chess"
    wm iconname $b "Chess"

    canvas $b.c -height 256 -width 256 \
	    -background #000000 -bd 0 -highlightthickness 0 


    set wdht 32

    for { set y 0 } { $y < 256 } { incr y 64 } {
        for { set x 0 } { $x < 256 } { incr x 64 } {
            $b.c create rectangle $x $y \
		[expr $x+$wdht] [expr $y+$wdht] -fill #f0f0f0 -outline ""
	}

        set y2 [expr $y + 32]
        for { set x 32 } { $x < 256 } { incr x 64 } {
            $b.c create rectangle $x $y2 \
                [expr $x+$wdht]  [expr $y2+$wdht] -fill #f0f0f0 -outline ""
	}
    }


    label $b.l -anchor c -text "NO MOO ONLY CHESS!" \
	-bd 2 -highlightthickness 0 -relief groove

    pack configure $b.c -side top
    pack configure $b.l -side bottom -fill x

    bind $b.c <1>                "chess.pick $b %x %y"
    bind $b.c <B1-Motion>        "chess.drag $b %x %y"
    bind $b.c <B1-ButtonRelease> "chess.drop $b %x %y"

    chess.build_images
}

proc chess.piece_colour { piece } {
    if { $piece == "" } { return "" }
    if { [string toupper $piece] == $piece } {
	return "white"
    } {
	return "black"
    }
}

proc chess.piece_at_xy { x y } {
    global chess_pieces
    foreach key [array names chess_pieces] {
	if { [string match "xy:*" $key] == 1 } {
	    if { ($x == [lindex $chess_pieces($key) 0]) &&
		 ($y == [lindex $chess_pieces($key) 1]) } {
		 set id [lindex [split $key ":"] 1]
		 return $chess_pieces(id:$id)
            }
	}
    }
    return ""
}

proc chess.pick { board x y } {
    global chess_piece chess_pieces chess_x chess_y chess_bitmap \
	chess_my_colour tkmooLibrary image_data
    set id [$board.c find withtag current]
    set chess_piece ""
    catch { set chess_piece $chess_pieces(id:$id) }

    if { $chess_piece == "" } { return }
    if { [chess.piece_colour $chess_piece] != $chess_my_colour } { return }

    set chess_x [lindex $chess_pieces(xy:$id) 0]
    set chess_y [lindex $chess_pieces(xy:$id) 1]

    set ghost_x [expr $chess_x * 32 - 16]
    set ghost_y [expr $chess_y * 32 - 16]

    .chessboard.c create image $ghost_x $ghost_y -image chess_$chess_bitmap($chess_piece).stationary_ghost \
	-tags CHESS_STATIONARY_GHOST

    .chessboard.c delete CHESS_GHOST
    .chessboard.c create image $x $y -image chess_$chess_bitmap($chess_piece).$chess_my_colour \
	-tags CHESS_GHOST
}

proc chess.drag { board x y } {
    global chess_piece chess_bitmap chess_my_colour \
        tkmooLibrary 

    if { $chess_piece == "" } { return }
    if { [chess.piece_colour $chess_piece] != $chess_my_colour } { return }

    .chessboard.c delete CHESS_GHOST
    .chessboard.c create image $x $y -image chess_$chess_bitmap($chess_piece).$chess_my_colour \
	-tags CHESS_GHOST
}


proc chess.physical_xy_to_chess_xy { px py colour } {
    if { $colour == "black" } {
	set x $px
	set y $py
    } {
	set x [expr 8 - $px + 1]
	set y [expr 8 - $py + 1]
    }
    return [list $x $y]
}

proc chess.drop { board x y } {
    global chess_piece chess_board chess_x chess_y chess_my_colour \
	chess_sequence

    .chessboard.c delete CHESS_GHOST CHESS_STATIONARY_GHOST

    if { $chess_piece == "" } { return }
    if { [chess.piece_colour $chess_piece] != $chess_my_colour } { return }

    set board_x [expr int($x / 32) + 1]
    set board_y [expr int($y / 32) + 1]

    if { ($chess_x != $board_x) || ($chess_y != $board_y) } {

	set source [chess.physical_xy_to_chess_xy $chess_x $chess_y $chess_my_colour]
	set target [chess.physical_xy_to_chess_xy $board_x $board_y $chess_my_colour]
	set x1 [lindex $source 0]
	set y1 [lindex $source 1]
	set x2 [lindex $target 0]
	set y2 [lindex $target 1]

        set victim [chess.piece_at_xy $board_x $board_y]
        if { [chess.piece_colour $victim] == $chess_my_colour } { 
	    return 
        }

	io.outgoing "move $x1 $y1 $x2 $y2 $chess_sequence on $chess_board(.chessboard)"
    }
}
#
#

proc xmcp11.do_chess-board {} {
    if { [xmcp11.authenticated] != 1 } {
	return;
    }
    set which		[request.current]
    set object		[request.get $which object]
    set board		[request.get $which board]
    set turn		[request.get $which turn]
    set colour		[request.get $which colour]
    set sequence	[request.get $which sequence]
    chess.SCboard $object $board $turn $colour $sequence
}
#
#
