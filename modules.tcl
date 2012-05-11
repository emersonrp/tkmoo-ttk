
set modules_module_deferred 0
set modules_module_ok 1

proc modules.module_deferred {} {
    global modules_module_deferred
    return $modules_module_deferred
}

proc modules.module_ok {} {
    global modules_module_ok
    return $modules_module_ok
}

proc modules.debug {} {
    set debug [worlds.get_generic Off {} {} ModulesDebug]
    if { [string tolower $debug] == "on" } {
        return 1
    }
    return 0
}

proc modules.reconfigure_fonts {} {
    global client_event_callbacks
    foreach module $client_event_callbacks(reconfigure_fonts) {
        if { [catch $module.reconfigure_fonts rv] && [modules.debug] } {
            window.displayCR "Internal Error in $module.reconfigure_fonts: $rv" window_highlight
        }
    }
}

proc modules.start {} {
    global client_event_callbacks
    foreach module $client_event_callbacks(start) {
        if { [catch $module.start rv] && [modules.debug] } {
            window.displayCR "Internal Error in $module.start: $rv" window_highlight
        }
    }
}

proc modules.stop {} {
    global client_event_callbacks
    foreach module $client_event_callbacks(stop) {
        if { [catch $module.stop rv] && [modules.debug] } {
            window.displayCR "Internal Error in $module.stop: $rv" window_highlight
        }
    }
}

proc modules.incoming_2 event {
    global modules_module_ok modules_module_deferred \
       client_event_callbacks

    foreach module $client_event_callbacks(incoming_2) {
        if { [catch { $module.incoming_2 $event } rv] && [modules.debug] } {
            window.displayCR "Internal Error in $module.incoming_2: $rv" window_highlight
        } {
            if { $rv == $modules_module_ok } {
                return $rv
            }
        }
    }

    return $modules_module_deferred
}

proc modules.incoming event {
    global modules_module_ok modules_module_deferred \
       client_event_callbacks

    foreach module $client_event_callbacks(incoming) {
        if { [catch { $module.incoming $event } rv] && [modules.debug] } {
            window.displayCR "Internal Error in $module.incoming: $rv" window_highlight
        } {
            if { $rv == $modules_module_ok } {
                return $rv
        }
        }
    }

    return $modules_module_deferred
}

proc modules.outgoing line {
    global modules_module_ok modules_module_deferred \
       client_event_callbacks

    foreach module $client_event_callbacks(outgoing) {
        if { [catch { $module.outgoing $line } rv] && [modules.debug] } {
            window.displayCR "Internal Error in $module.outgoing: $rv" window_highlight
        } {
            if { $rv == $modules_module_ok } {
                return $rv
            }
        }
    }

    return $modules_module_deferred
}

proc modules.client_connected {} {
    global modules_module_ok modules_module_deferred \
       client_event_callbacks

    foreach module $client_event_callbacks(client_connected) {
        if { [catch $module.client_connected rv] && [modules.debug] } {
            window.displayCR "Internal Error in $module.client_connected: $rv" window_highlight
        } {
            if { $rv == $modules_module_ok } {
                return $rv
            }
        }
    }
    return $modules_module_deferred
}

proc modules.client_disconnected {} {
    global modules_module_ok modules_module_deferred \
       client_event_callbacks

    foreach module $client_event_callbacks(client_disconnected) {
        if { [catch $module.client_disconnected rv] && [modules.debug] } {
            window.displayCR "Internal Error in $module.client_disconnected: $rv" window_highlight
        } {
            if { $rv == $modules_module_ok } {
                return $rv
            }
        }
    }
    return $modules_module_deferred
}
