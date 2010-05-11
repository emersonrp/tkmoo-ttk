
proc mail.create {} {
	if { [winfo exists .mail] == 1 } {
		return;
	}

	toplevel .mail -bd 0 -highlightthickness 0

	window.place_nice .mail

	ttk::frame .mail.folders
	listbox .mail.folders.l -height 3 \
		-background #f0f0f0 \
		-yscrollcommand ".mail.folders.s set" \
		-font [fonts.fixedwidth] \
				-highlightthickness 0
	ttk::scrollbar .mail.folders.s -command ".mail.folders.l yview"
	pack configure .mail.folders.l -side left -fill x \
					-expand 1
	pack configure .mail.folders.s -side right -fill y

	ttk::frame .mail.messages
	listbox .mail.messages.l -height 5 \
		-background #f0f0f0 \
		-yscrollcommand ".mail.messages.s set" \
		-font [fonts.fixedwidth] \
		-highlightthickness 0
	ttk::scrollbar .mail.messages.s -command ".mail.messages.l yview"
	pack configure .mail.messages.l -side left -fill x \
		-expand 1
	pack configure .mail.messages.s -side right -fill y

	ttk::frame .mail.message
	text .mail.message.t -wrap word \
		-yscrollcommand ".mail.message.s set" \
		-font [fonts.fixedwidth] \
		-setgrid 1 \
		-cursor {} \
		-highlightthickness 0
	ttk::scrollbar .mail.message.s -command ".mail.message.t yview"
	pack configure .mail.message.s -side right -fill y
	pack configure .mail.message.t -side left -fill both -expand 1

	ttk::frame .mail.controls
	ttk::button .mail.controls.n -text "Next" -state disabled
	ttk::button .mail.controls.p -text "Prev" -state disabled
	ttk::button .mail.controls.d -text "Delete" -state disabled
	ttk::button .mail.controls.r -text "Reply" -state disabled
	ttk::button .mail.controls.c -text "Close" -command "destroy .mail"
	pack configure .mail.controls.n -side left
	pack configure .mail.controls.p -side left
	pack configure .mail.controls.d -side left
	pack configure .mail.controls.r -side left
	pack configure .mail.controls.c -side right

	pack configure .mail.folders -side top -fill x
	pack configure .mail.messages -side top -fill x
	pack configure .mail.message -side top -fill both -expand 1
	pack configure .mail.controls -side top -fill x

	bind .mail.folders.l <ButtonRelease-1> {
		set box [%W index @%x,%y]
		set folder $mail_folders($box)
		io.outgoing "@xmail-messages on $folder"
	}

	bind .mail.messages.l <ButtonRelease-1> {
		set box [%W index @%x,%y]
		set folder_msgno $mail_messages($box)
		set folder [lindex $folder_msgno 0]
		set msgno  [lindex $folder_msgno 1]
		if { [mail.in_cache $folder $msgno] == 1 } {
			mail.message $folder $msgno [mail.cache_get $folder $msgno]
		} {
			io.outgoing "@xmail-message $msgno on $folder"
		}
	}

	.mail.message.t configure -state disabled
}

proc mail.folders { lines } {
	global mail_folders
	.mail.folders.l delete 0 end
	catch { unset mail_folders }
	foreach line $lines {
		catch { unset foo }
		util.populate_array foo $line
		set box [.mail.folders.l index end]
		set mail_folders($box) $foo(folder)
		.mail.folders.l insert end $foo(foldersum)
	}
}

proc mail.messages { folder last lines } {
	global mail_messages
	.mail.messages.l delete 0 end
	catch { unset mail_messages }
	foreach line $lines {
		catch { unset foo }
		util.populate_array foo $line
		set box [.mail.messages.l index end]
		set mail_messages($box) [list $folder $foo(msgno)]
		.mail.messages.l insert end $foo(msgsum)
	}
}

proc mail.message { folder msgno lines } {
	mail.cache_message $folder $msgno $lines

	.mail.message.t configure -state normal
	.mail.message.t delete 0.1 end

	if { $lines != {} } {
		.mail.message.t insert insert [lindex $lines 0]
		set lines [lrange $lines 1 end]
	}
	foreach line $lines {
		.mail.message.t insert insert "\n$line"
	}

	.mail.message.t configure -state disabled
}

proc mail.cache_get { folder msgno } {
	global mail_cache
	return $mail_cache($folder:$msgno)
}

proc mail.cache_message { folder msgno lines } {
	global mail_cache
	set mail_cache($folder:$msgno) $lines
}

proc mail.in_cache { folder msgno } {
	global mail_cache
	return [info exists mail_cache($folder:$msgno)]
}

#
#
proc xmcp11.do_xmail-folders* {} {
	if { [xmcp11.authenticated] == 1 } {
		request.set current xmcp11_multiline_procedure "xmail-folders*"
	}
}

proc xmcp11.do_callback_xmail-folders* {} {
	set which	[request.current]
	set lines	[request.get $which _lines]

	mail.create
	mail.folders $lines
}

proc xmcp11.do_xmail-messages* {} {
	if { [xmcp11.authenticated] == 1 } {
		request.set current xmcp11_multiline_procedure "xmail-messages*"
	}
}

proc xmcp11.do_callback_xmail-messages* {} {
	set which	[request.current]
	set folder	[request.get $which folder]
	set last	[request.get $which last]
	set lines	[request.get $which _lines]

	mail.create
	mail.messages $folder $last $lines
}

proc xmcp11.do_xmail-message* {} {
	if { [xmcp11.authenticated] == 1 } {
		request.set current xmcp11_multiline_procedure "xmail-message*"
	}
}

proc xmcp11.do_callback_xmail-message* {} {
	set which	[request.current]
	set folder	[request.get $which folder]
	set msgno	[request.get $which msgno]
	set lines	[request.get $which _lines]

	mail.create

	foreach line $lines {
		catch { unset foo }
		util.populate_array foo $line
		lappend real_lines $foo(text)
	}

	mail.message $folder $msgno $real_lines
}
#
#


