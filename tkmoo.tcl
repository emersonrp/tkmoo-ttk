#!
set tkmooLibrary build/.tkMOO-lite
# tkMOO-SE is Copyright (c) Stephen Alderman 2003-2006.
# 
# 	All Rights Reserved
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
set tkmooVersion "0.3"
set tkmooBuildTime "Fri Jun 23 18:05:05 GMT 2006"

if { $tcl_platform(platform) == "macintosh" } {
    catch { console hide }
}
#
#

if {[info tclversion] < 7.5} {
    puts stderr "This application requires Tcl 7.5 or better.  This is only Tcl [info tclversion]"
    exit 1
}
if {[regexp {7\.5(a|b).} [info patchlevel]]} {
    puts stderr "This application will not work with a Tcl alpha or beta release"
    exit 1
}
if {![info exists tk_version]} {
    puts stderr "This application requires Tk"
    exit 1
}
if {$tk_version < 4.1} {
    puts stderr "This application requires Tk 4.1 or better.  This is only Tk $tk_version"
    exit 1
}
if {[regexp {4\.1(a|b).} $tk_patchLevel]} {
    puts stderr "This application will not work with a Tk alpha or beta release"
    exit 1
}

source "db.tcl"
source "client.tcl"
source "modules.tcl"
source "bindings.tcl"
source "default.tcl"
source "history.tcl"
source "help.tcl"
source "fonts.tcl"
source "colours.tcl"
source "window.tcl"
source "io.tcl"
source "util.tcl"
source "worlds.tcl"
source "edit.tcl"


proc initapi.rcfile {} {
    global tcl_platform env

    set files {}
    switch $tcl_platform(platform) {
        macintosh {
            lappend files [file join [pwd] tkmoo-se.RC]
	    if { [info exists env(PREF_FOLDER)] } {
                lappend files [file join $env(PREF_FOLDER) tkmoo-se.RC]
	    }
        }
        windows {
	    lappend files [file join [pwd] tkmoo.res]
	    if { [info exists env(TKMOO_LIB_DIR)] } {
                lappend files [file join $env(TKMOO_LIB_DIR) tkmoo tkmoo.res]
	    }
	    if { [info exists env(HOME)] } {
                lappend files [file join $env(HOME) tkmoo tkmoo.res]
	    }
        }
        unix -
        default {
            lappend files [file join [pwd] .tkmoo-serc]
	    if { [info exists env(TKMOO_LIB_DIR)] } {
                lappend files [file join $env(TKMOO_LIB_DIR) .tkmoo-serc]
	    }
	    if { [info exists env(HOME)] } {
                lappend files [file join $env(HOME) .tkmoo-serc]
	    }
        }
    }

    foreach file $files {
        if { [file exists $file] } {
            return $file
        }
    }
    
    return ""
}

default.options

set rcfile [initapi.rcfile]

if { ($rcfile != "") && [file readable $rcfile] } {
    option readfile $rcfile userDefault
}

window.buildWindow
#
#
source "ui.tcl"
source "request.tcl"
source "imagedata.tcl"
source "xmcp11.tcl"
source "mcp.tcl"
source "desktop.tcl"
source "whiteboard.tcl"
source "awns.tcl"
source "localedit.tcl"
source "tkmootag.tcl"
source "logging.tcl"
source "hashhash_edit.tcl"
source "mail.tcl"
source "chess.tcl"
source "macmoose.tcl"
source "edittriggers.tcl"

window.menu_tools_add "@paste selection" {window.paste_selection}
#
#
source "who.tcl"
source "open.tcl"
source "preferences.tcl"
source "colourchooser.tcl"
source "fontchooser.tcl"
source "plugin.tcl"

set main_host		""
set main_port		""
set main_login		""
set main_password	""
set main_script		""

set main_usage "Usage: tkmoo \[-dir <dir>\] \[host \[port 23\]\]
       tkmoo \[-dir <dir>\] -world <world>
       tkmoo \[-dir <dir>\] -f <file>"

set main_unprocessed {}

while { $argv != {} } {
    set main_this [lindex $argv 0]
    set argv [lrange $argv 1 end]
    switch -- $main_this {
        -f {
            set main_arg(-f) [lindex $argv 0]
            set argv [lrange $argv 1 end]
        }
        -world {
            set main_arg(-world) [lindex $argv 0]
            set argv [lrange $argv 1 end]
        }
        -dir {
            set main_arg(-dir) [lindex $argv 0]
            set argv [lrange $argv 1 end]
        }
        default {
            lappend main_unprocessed $main_this
            if { [string match {-*} $main_this] } {
            }
        }
    }
}

set main_error_str ""
if { [info exists main_arg(-dir)] } {

    if { [file isdirectory $main_arg(-dir)] &&
         [file readable $main_arg(-dir)] } {
        set env(TKMOO_LIB_DIR) $main_arg(-dir)
    } {
        append main_error_str "Error: can't read directory '$main_arg(-dir)'\n"
        append main_error_str "$main_usage"
    }
}

plugin.source
client.start 

if { ($main_error_str == "") && [info exists main_arg(-f)] } {


    if { ($main_arg(-f) == [worlds.file]) ||
	 ($main_arg(-f) == [edittriggers.file]) } {
        append main_error_str "Error: can't read file '$main_arg(-f)'\n"
        append main_error_str "$main_usage"
    } elseif { [file isfile $main_arg(-f)] &&
               [file readable $main_arg(-f)] } {

        set file $main_arg(-f)
        set lines [worlds.read_worlds $file]
        set worlds [worlds.apply_lines $lines]
        global worlds_worlds
        set worlds_worlds [concat $worlds_worlds $worlds]

	foreach world $worlds {
	    worlds.set $world "MustNotSave" 1
	}

        if { $worlds != {} } {
            client.connect_world [lindex $worlds 0]
        }
    } {
        append main_error_str "Error: can't read file '$main_arg(-f)'\n"
        append main_error_str "$main_usage"
    }

} elseif { ($main_error_str == "") && [info exists main_arg(-world)] } {


    set name $main_arg(-world)
    set matches [worlds.match_world "*$name*"]
    if { [llength $matches] == 1 } {
        client.connect_world [lindex $matches 0] 
    }
    if { [llength $matches] > 1 } {
        append main_error_str "'$name' could match any of the following Worlds:\n"
        foreach w $matches {
            append main_error_str "  [worlds.get $w Name]\n"
        }
    }   
    if { [llength $matches] == 0 } {
        append main_error_str "No World with Name matching '$name'\n"
    }   

} elseif { ($main_error_str == "") && ([llength $main_unprocessed] == 1) } {

    set host [lindex $main_unprocessed 0]
    set port 23

    set main_host $host
    set main_port $port
    if { ($main_host != "") && ($main_port != "") } {
        io.connect $main_host $main_port
    }

    if { $main_login != "" } {
        io.outgoing "connect $main_login $main_password"
    }

} elseif { ($main_error_str == "") && ([llength $main_unprocessed] == 2) } {

    set host [lindex $main_unprocessed 0]
    set port [lindex $main_unprocessed 1]
    set port [string trimleft $port "0"]
    if { [regexp {^[0-9]*$} $port] } {

        set main_host $host
        set main_port $port
        if { ($main_host != "") && ($main_port != "") } {
            io.connect $main_host $main_port
        }

        if { $main_login != "" } {
            io.outgoing "connect $main_login $main_password"
        }

    } {
        append main_error_str "Error: non numeric port '$port'\n"
        append main_error_str "$main_usage"
    }

} elseif { ($main_error_str == "") && ($main_unprocessed != {}) } {

    append main_error_str "Error: unknown arguments '$main_unprocessed'\n"
    append main_error_str "$main_usage"

} elseif { ($main_error_str == "") } {


}

if { $main_error_str != "" } {
    window.displayCR $main_error_str window_highlight
}

