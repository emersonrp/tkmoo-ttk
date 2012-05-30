#
#    tkMOO
#    ~/.tkMOO-light/plugins/pretty.tcl
#

# tkMOO-light is Copyright (c) Andrew Wilson 1994,1995,1996,1997,1998,1999
#                                            2000,2001
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

# Adds the Edit->'Prettyprint MOO' menu option to the local editor.
# Tries to correctly indent MOO code, but does no other formatting.

client.register pretty start

proc pretty.start {} {
    edit.add_edit_function "Prettyprint MOO" pretty.prettyprint
}

proc pretty.prettyprint w {
    # we might want to disable this feature if the 'type' doesn't match
    # set type ""
    # catch { set type [edit.get_type $w] }
    # if { $type != "moo-code" } { return }

    set blank "                                                           "

    # format for MOO-code
    set lines [edit.get_text $w]
    set out {}
    set indent 0
    foreach line $lines {
        set l [string trimleft $line]

        if { [regexp -nocase {^(endif|endwhile|endfor|elseif|else|endfork|endtry|finally)( |;|$)} $l] } {
            incr indent -2
        }

        if { $indent < 0 } { set indent 0 }

        # redraw the line
        set o "[string range $blank 0 [expr $indent - 1]]$l"
        lappend out $o

        if { [regexp -nocase {^(if|while|for|elseif|else|fork|try|finally)( |;|$)} $l] } {
            incr indent 2
        }
    }

    # update the widget, display the same part of the file
    set yview [$w.t yview]
    $w.t delete 1.0 end
    edit.set_text $w $out
    edit.dispatch $w load [list [list range [list 1.0 [$w.t index end]]]]
    $w.t yview moveto [lindex $yview 0]
}
