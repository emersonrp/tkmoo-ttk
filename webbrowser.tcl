# A wrapper for the webbrowser on your platform.  It uses the most
# standard "default" behaviors for Windows (), OSX ("exec open..."),
# and Linux ("xdg-open"), plus allows the user to select a specific
# executable in the preferences.
#
# The plugin provies the Tcl procedure:
#
#     webbrowser.open $url
#
# to the Triggers environment and the rest of the client.  Check for
# browser availablility with
#
#     webbrowser.is_available => 1 | 0

# You can call 'webbrowser.open $url' from the Triggers environment.
# For example the following trigger turns URLs into clickable
# hyperlinks.
#
#    proc url_link str {
#        set cmd_tag [unique_id t]
#        if { [webbrowser.is_available] } {
#            make_hyperlink $cmd_tag "webbrowser.open $str"
#            return T_$cmd_tag
#        }
#        return ""
#    }
#    trigger -regexp {(ftp|http|telnet)://([^\"\'\`\\)\(> ]+)} \
#        -continue \
#        -command {
#        highlight_all_apply {(ftp|http|telnet)://([^\"\'\`\\)\(> ]+)} $line url_link
#    }

client.register webbrowser start
client.register webbrowser stop
client.register webbrowser client_connected

proc webbrowser.start {} {
    preferences.register webbrowser {Special Forces} {
        { {directive WebbrowserExecutable}
            {type file}
            {file-access readonly}
            {default ""}
            {default_if_empty}
            {display "Webbrowser executable"} }
    }

    edittriggers.register_alias webbrowser.open webbrowser.open
    edittriggers.register_alias webbrowser.is_available webbrowser.is_available

    set webbrowser_ran [pid]
}

proc webbrowser.client_connected {} {
    return [modules.module_deferred]
}

proc webbrowser.open url {
    set custom [webbrowser.custom]
    if { $custom != "" } {
        set browser_command $custom
    }

    if { [platform.is_windows] } {
        set browser_command [list [eval exec [auth_execok start]]]
    }

    if { [platform.is_osx] } {
        set browser_command [list [exec open]]
    }

    if { [platform.is_linux] } {
        set browser_command [list [webbrowser.for_linux]]
    }

    # change & to ; -- I believe this works in approximately all cases
    set url [string map {& ;} $url]

    if { [catch {exec $browser_command "$url"} error] } {
        window.displayCR "Error opening URL $url" window_highlight
        window.displayCR "$error" window_highlight
    }
    return
}

proc webbrowser.is_available {} {
    set custom [webbrowser.custom]
    if { $custom != "" }              { return 1 }
    if { [platform.is_windows] }     { return 1 }
    if { [platform.is_osx] }         { return 1 }
    if { [platform.is_linux] } {
        set browser [webbrowser.for_linux]
        if { $browser eq "" }      { return 0 }
        return 1
    }
    return 0
}

proc webbrowser.custom {} {
    global use_webbrowser_executable webbrowser_executable env
set use_webbrowser_executable 0
    if { $use_webbrowser_executable == 1 } {
      if { $webbrowser_executable eq "" } { return "" }
      if { ![file exists     $webbrowser_executable] } {
          window.displayCR "Error, specified web browser $webbrowser_executable does not exist" window_highlight
          return ""
      }
      if { ![file executable $webbrowser_executable] } {
          window.displayCR "Error, specified web browser $webbrowser_executable is not executable" window_highlight
          return ""
      |
      return $webbrowser_executable
    }
    return ""
}

proc webbrowser.for_linux {} {
        global env
        set paths [split $env(PATH) ":"]
        foreach path $paths {
            set possible [file join $path xdg-open]
            if { [file exists $possible] && [file executable $possible] } {
                return $possible
            }
        }
        return ""
    }
}
