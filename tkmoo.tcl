package require Tcl 8.5

#!
set tkmooLibrary build/.tkMOO-lite

set home [ file dirname [ info script ]]

set tkmooVersion "tkmoo-ttk 0.1"

if {[info tclversion] < 8.5} {
    puts stderr "This application requires Tcl 8.5 or better.  This is only Tcl [info tclversion]"
    exit 1
}
if {![info exists tk_version]} {
    puts stderr "This application requires Tk"
    exit 1
}
if {$tk_version < 8.5} {
    puts stderr "This application requires Tk 8.5 or better.  This is only Tk $tk_version"
    exit 1
}

source [ file join $home "db.tcl" ]
source [ file join $home "platform.tcl" ]
source [ file join $home "client.tcl" ]
source [ file join $home "modules.tcl" ]
source [ file join $home "bindings.tcl" ]
source [ file join $home "default.tcl" ]
source [ file join $home "history.tcl" ]
source [ file join $home "help.tcl" ]
source [ file join $home "fonts.tcl" ]
source [ file join $home "colours.tcl" ]
source [ file join $home "window.tcl" ]
source [ file join $home "io.tcl" ]
source [ file join $home "util.tcl" ]
source [ file join $home "worlds.tcl" ]
source [ file join $home "edit.tcl" ]


proc initapi.rcfile {} {
    global env

    set files {}
    lappend files [file join [pwd] tkmoo.res]
    if { [info exists env(TKMOO_LIB_DIR)] } {
        lappend files [file join $env(TKMOO_LIB_DIR) tkmoo tkmoo.res]
        lappend files [file join $env(TKMOO_LIB_DIR) .tkmoorc]
    }
    if { [info exists env(HOME)] } {
        lappend files [file join $env(HOME) tkmoo tkmoo.res]
        lappend files [file join $env(HOME) .tkmoorc]
    }
    lappend files [file join [pwd] .tkmoorc]

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
source [ file join $home "ui.tcl" ]
source [ file join $home "request.tcl" ]
source [ file join $home "mcp.tcl" ]
source [ file join $home "localedit.tcl" ]
source [ file join $home "tkmootag.tcl" ]
source [ file join $home "logging.tcl" ]
source [ file join $home "hashhash_edit.tcl" ]
source [ file join $home "macmoose.tcl" ]
source [ file join $home "edittriggers.tcl" ]

window.menu_tools_add "@paste selection" {window.paste_selection}
#
#
source [ file join $home "open.tcl" ]
source [ file join $home "preferences.tcl" ]
source [ file join $home "colourchooser.tcl" ]
source [ file join $home "fontchooser.tcl" ]
source [ file join $home "plugins.tcl" ]

set main_host        ""
set main_port        ""
set main_login       ""
set main_password    ""
set main_script      ""

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

# set up the platform convenience thingie
global tcl_platform platform
if { $tcl_platform(platform) == "windows" }          { set platform windows }
if { $tcl_platform(platform) == "unix" &&
    [string tolower $tcl_platform(os)] == "darwin" } { set platform osx }
if { $tcl_platform(platform) == "unix" &&
    [string tolower $tcl_platform(os)] != "darwin" } { set platform linux }

# debug me daddy
proc stacktrace {} {
    set stack "Stack trace:\n"
    for {set i 1} {$i < [info level]} {incr i} {
    set lvl [info level -$i]
    set pname [lindex $lvl 0]
    append stack [string repeat " " $i]$pname
    foreach value [lrange $lvl 1 end] arg [info args $pname] {
        if {$value eq ""} {
                info default $pname $arg value
        }
        append stack " $arg='$value'"
    }
    append stack \n
    }
    return $stack
}
