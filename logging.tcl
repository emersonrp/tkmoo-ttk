

client.register logging start 20
client.register logging stop 20
client.register logging client_connected 20
client.register logging client_disconnected 20
client.register logging incoming 20
client.register logging incoming_2
client.register logging outgoing 20



proc logging.client_connected {} {
	global logging_enabled logging_logfilename logging_logfilename_default

	set use [string tolower [worlds.get_generic on {} {} UseModuleLogging]]
	if { $use == "on" } {
		set logging_enabled 1
	} elseif { $use == "off" } {
		set logging_enabled 0
	}

	set logging_logfilename [worlds.get_generic $logging_logfilename_default {} {} LogFile]

	window.menu_preferences_state "Logging..." normal

	return [modules.module_deferred]
}

proc logging.client_disconnected {} {
	global logging_enabled logging_logfilename logging_logfilename_default
	set logging_enabled 0
	set logging_logfilename $logging_logfilename_default
	logging.stop
	window.menu_preferences_state "Logging..." disabled
	return [modules.module_deferred]
}

proc logging.start {} {
	global logging_enabled logging_logfilename logging_logfilename_default \
	logging_logfile logging_task

	set logging_enabled 0
	set logging_logfilename_default [file join [pwd] tkmoo.log]
	set logging_logfilename $logging_logfilename_default
	set logging_logfile ""
	set logging_task 0
}

window.menu_preferences_add "Logging..." logging.create_dialog
window.menu_preferences_state "Logging..." disabled

proc logging.stop {} {
	global logging_logfile logging_task
	after cancel $logging_task
	catch { 
		puts $logging_logfile "LOG FINISHED [clock format [clock seconds]]"
		close $logging_logfile 
		set logging_logfile ""
	}
}

proc logging.incoming event {
	db.set $event logging_original_line [db.get $event line]
	return [modules.module_deferred]
}

proc logging.incoming_2 event {
	global logging_enabled logging_logfilename logging_logfile

	if { $logging_enabled == 0 } {
		catch { close $logging_logfile }
		return [modules.module_deferred]
	}

	if { $logging_logfile == "" } {
		set logging_logfile [open $logging_logfilename "a+"]
		puts $logging_logfile "LOG STARTED [clock format [clock seconds]]"
	}

	set line [db.get $event logging_original_line]

	if { $logging_logfile != "" } {
		if { ! [db.exists $event logging_ignore_incoming] } {
			puts $logging_logfile "LOG <: $line"
			logging.flush
		}
	} {
		window.displayCR "Couldn't open logfile '$logging_logfilename'." window_highlight
	}
	db.set $event logging_ignore_incoming 0
	return [modules.module_deferred]
}

proc logging.outgoing line {
	global logging_enabled logging_logfilename logging_logfile
	if { $logging_enabled == 0 } {
		catch { close $logging_logfile }
		return [modules.module_deferred]
	}
	if { $logging_logfile == "" } {
		set logging_logfile [open $logging_logfilename "a+"]
		puts $logging_logfile "LOG STARTED [clock format [clock seconds]]"
	}
	if { $logging_logfile != "" } {
		puts $logging_logfile "LOG >: $line"
		logging.flush
	}
	return [modules.module_deferred]
}

proc logging.flush {} {
	global logging_logfile logging_task
	after cancel $logging_task
	set logging_task [after idle flush $logging_logfile]
}

proc logging.create_dialog {} {
	global logging_enabled logging_logfilename \
			logging_old_enabled logging_old_logfilename

	set logging_old_enabled $logging_enabled
	set logging_old_logfilename $logging_logfilename

	set l .logging
	catch { destroy $l }
	toplevel $l
	window.configure_for_macintosh $l

	global tcl_platform
	if { $tcl_platform(platform) != "macintosh" } {
		bind $l <Escape> "logging.close_dialog"
	}

	window.place_nice $l

	wm iconname $l "Logging"
	wm title $l "Logging"

	ttk::frame $l.t
	ttk::label $l.t.le -text "Log file name" -anchor w -width 20 -justify left
	entry $l.t.e -textvariable logging_logfilename -width 30 \
		-font [fonts.fixedwidth]
	pack $l.t.le -side left
	pack $l.t.e -side left

	ttk::frame $l.m
	ttk::label $l.m.l -text "Write to log file" -anchor w -width 20 -justify left
	ttk::checkbutton $l.m.b -variable logging_enabled
	pack $l.m.l -side left
	pack $l.m.b -side left

	ttk::frame $l.b
	ttk::button $l.b.o -text " Ok " -command "logging.close_dialog"
	ttk::button $l.b.c -text "Cancel" -command "logging.restore_dialog"
	pack $l.b.o $l.b.c -side left \
		-padx 5 -pady 5

	pack $l.t -side top -fill x
	pack $l.m -side top -fill x
	pack $l.b -side top 

	window.focus $l.t.e
}

proc logging.restore_dialog {} {
	global logging_enabled logging_logfilename \
			logging_old_enabled logging_old_logfilename
	set logging_enabled $logging_old_enabled
	set logging_logfilename $logging_old_logfilename
	set l .logging
	destroy $l
}

proc logging.close_dialog {} {
	global logging_enabled logging_logfile
	set l .logging
	if { $logging_enabled == 0 } {
		catch { close $logging_logfile }
		set logging_logfile ""
	}
	destroy $l
	logging.set_logging_info_from_dialog
}

proc logging.set_logging_info_from_dialog {} {
	global logging_enabled logging_logfilename
	if { [set world [worlds.get_current]] != "" } {
		if { $logging_enabled } {
			set value On
		} {
			set value Off
		}
		worlds.set_if_different $world UseModuleLogging $value
		worlds.set_if_different $world LogFile $logging_logfilename
	}
}
#
#
