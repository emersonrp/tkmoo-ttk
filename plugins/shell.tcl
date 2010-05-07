#
#       tkMOO
#       ~/.tkMOO-lite/plugins/shell.tcl
#

# tkMOO-light is Copyright (c) Andrew Wilson 1994,1995,1996,1997,1998,1999
#                                            2000,2001,2002
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

# provide various shell access commands

# TODO
# output to main window (with some kind of prefix string?)
# output to separate 'shell' window (read only)
# output to /dev/null
# dialog box entry for shelled command input

# A useful macro for the triggers editor:
# 
# macro -regexp {^/shell (.*)$} \
#      -command { shell.shell $m1 }
#
# The /shell command sends its arguments to a shell eg:
#
#    /shell ls -l

client.register shell start 60

proc shell.start {} {
    edittriggers.register_alias shell.shell shell.shell
    window.menu_tools_add "Shell selection" shell.do_selection
}


proc shell.do_selection {} {
    set selection [selection get]
    if { $selection != "" } {
        shell.shell $selection
    }
}

proc shell.protect_tcl_meta str {
    regsub -all {([\$\"\[\\])} $str {\\\1} str
    return $str
}

proc shell.exec.tcsh cmd {
    global env
    return [exec -- $env(SHELL) -c "$cmd"]
}

proc shell.exec.bash cmd {
    global env
    return [exec -- $env(SHELL) -c "$cmd"]
}

proc shell.exec.csh cmd {
    global env
    return [exec -- $env(SHELL) -c "$cmd"]
}

proc shell.shell cmd {
    global env
    set shell [file tail $env(SHELL)]
    if { [info procs shell.exec.$shell] != {} } {
        if { [catch {set output [shell.exec.$shell $cmd]} rv] } {
            window.displayCR "$rv" window_highlight
        } {
            if { $output != "" } {
                window.displayCR "$output"
            }
        }
    } {
        window.displayCR "Internal error (plugin shell.tcl): don't know how to deal with shell '$env(SHELL)'" window_highlight
    }
}
