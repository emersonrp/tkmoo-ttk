# Display a line of text in a subwindow, create the subwindow if
# it doesn't already exist.
#
# The plugin makes the command 'subwindow.display' available to
# the Triggers environment.  If your server uses communication channels
# it might send you lines of text like this:
#
#   [chatter] Fred says, "did anyone see the game last night?"
#   [auction] DragonLord says, "What am I bid for this fine sword?"
#
# You can use the following trigger to detect such lines and display
# them in different subwindows:
#
# trigger -regexp {^\[([^]]*)\] (.*)$} \
#         -command {
#             subwindow.display $m1 $m2
#         }
#
# Text entered in the subwindow's entry widget is prefixed with
# the string 'FROM SUBWINDOW channel-name ' and is then processed
# by the client as if it had been typed from the main window's input
# window.  This means that macros defined in the Triggers environment
# can intercept the message and rewrite it to suit the server's syntax
# for channel communications.
#
# If your server expects channel communication (to the 'chatter'
# channel) to be typed like this:
#
#   -chatter Hello!!
#
# You can use the following macro to detect input to the subwindow
# and convert the input to suit the server:
#
# macro -regexp {^FROM_SUBWINDOW ([^ ]*) (.*)$} \
#       -command {
#           io.outgoing "-$m1 $m2"
#       }

client.register subwindow start

proc subwindow.start {} {
    edittriggers.register_alias subwindow.display subwindow.display
}

proc subwindow.display {name {text ""}} {
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
    bind $win.e <Return> "subwindow.enter $win"
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

proc subwindow.enter win {
    global subwindow_db
    set line [$win.e get]
    $win.e delete 0 end
    client.outgoing "FROM_SUBWINDOW $subwindow_db($win:name) $line"
}
