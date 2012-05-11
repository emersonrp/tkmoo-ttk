#
#    ~/.tkMOO-light/plugins/subwindow.tcl
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

client.register chanwin start

proc chanwin.start {} {
    edittriggers.register_alias chanwin.display chanwin.display
}

proc chanwin.display {name label {text ""}} {
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
    frame $win.f
    label $win.f.lb -text $label
    entry $win.f.e \
        -highlightthickness 0 \
        -bd 1 \
        -background [colourdb.get pink]
    bind $win.e <Return> "chanwin.enter $win"
    bind $win.f.e <Return> "chanwind.enter $win"
    pack $win.f.lb -side left
    pack $win.f.e -side right -fill x -expand 1
    pack $win.f -side bottom -fill x
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

proc chanwin.enter win {
    global subwindow_db
    set line [$win.e get]
    $win.e delete 0 end
    client.outgoing "FROM_SUBWINDOW $subwindow_db($win:name) $line"
}

proc chanwind.enter win {
    global subwindow_db
    set line [$win.f.e get]
    $win.f.e delete 0 end
    client.outgoing "FROM_SUBWINDOWN $subwindow_db($win:name) $line"
}
