proc plugin.plugins_directories {} {
    set home [ file dirname [ info script ]]

    global tkmooLibrary env
    set dirs {}
    lappend dirs [file join $home plugins]
    if { [info exists env(TKMOO_LIB_DIR)] } {
        lappend dirs [file join $env(TKMOO_LIB_DIR) plugins]
    }
    if { [info exists env(HOME)] } {
        lappend dirs [file join $env(HOME) tkmoo plugins]
        lappend dirs [file join $env(HOME) .tkMOO-lite plugins]
    }
    lappend dirs [file join $tkmooLibrary plugins]
}

proc plugin.plugins_dir {} {
    foreach dir [plugin.plugins_directories] {
        if { [file exists $dir] &&
             [file isdirectory $dir] &&
             [file readable $dir] } {
            return $dir
        }
    }
    return ""
}

proc plugin.set_plugin_location location {
    global plugin_location
    set plugin_location $location
}
proc plugin.clear_plugin_location {} {
    global plugin_location
    unset plugin_location
}
proc plugin.plugin_location {} {
    global plugin_location
    if { [info exists plugin_location] } {
        return $plugin_location
    } {
        return INTERNAL
    }
}

proc plugin.source {} {
    set dir [plugin.plugins_dir]
    if { $dir == "" } {
        window.displayCR "Can't find plugins directory, searched for:" window_highlight
        foreach dir [plugin.plugins_directories] {
            window.displayCR "  $dir" window_highlight
        }
        return
    }

    set files [glob -nocomplain -- [file join $dir *.tcl]]
    foreach file $files {
        plugin.set_plugin_location $file
        source $file
    }
    set subdirs [glob -nocomplain -- [file join $dir *]]
    foreach subdir $subdirs {
        if { [file isdirectory $subdir] == 0 } { continue }
        set files [glob -nocomplain -- [file join $subdir *.tcl]]
        foreach file $files {
            plugin.set_plugin_location $file
        source $file
        }
    }
    plugin.clear_plugin_location
}
client.register registry start

proc registry.start {} {
    global tcl_platform

    if { $tcl_platform(platform) != "windows" } {
        return;
    }

    if { [catch { package require registry 1.0 }] } {
        return;
    }

    registry set {HKEY_CLASSES_ROOT\.tkm} {} TkmWorld sz
    registry set {HKEY_CLASSES_ROOT\.tkm} {Content Type} "application/x-tkm" sz
    registry set {HKEY_CLASSES_ROOT\TkmWorld}
    registry set {HKEY_CLASSES_ROOT\TkmWorld} {} TkmWorld sz
    registry set {HKEY_CLASSES_ROOT\TkmWorld\DefaultIcon}

    set executable [info nameofexecutable]

    registry set {HKEY_CLASSES_ROOT\TkmWorld\DefaultIcon} {} \
       "$executable" sz

    registry set {HKEY_CLASSES_ROOT\TkmWorld\shell}
    registry set {HKEY_CLASSES_ROOT\TkmWorld\shell\open}
    registry set {HKEY_CLASSES_ROOT\TkmWorld\shell\open\command}
    registry set {HKEY_CLASSES_ROOT\TkmWorld\shell\edit}
    registry set {HKEY_CLASSES_ROOT\TkmWorld\shell\edit\command}


    set directory [file dirname $executable]

    registry set {HKEY_CLASSES_ROOT\TkmWorld\shell\open\command} {} \
    "\"$executable\" -dir \"$directory\" -f \"%1\"" sz
    registry set {HKEY_CLASSES_ROOT\TkmWorld\shell\edit\command} {} \
    {notepad.exe "%1"} sz

}
