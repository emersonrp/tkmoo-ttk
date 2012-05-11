client.register beryllium start 60
proc beryllium.start {} {
    mcp21.register dns-net-beryllium-status 1.0 \
        dns-net-beryllium-status-msg_force beryllium.do_dns_net_beryllium_status_msg_force
    mcp21.register dns-net-beryllium-status 1.0 \
        dns-net-beryllium-status-ico_clr beryllium.dns-net-beryllium-status-ico_clr
    mcp21.register dns-net-beryllium-status 1.0 \
        dns-net-beryllium-status-ico_add beryllium.dns-net-beryllium-status-ico_add
    mcp21.register dns-net-beryllium-status 1.0 \
        dns-net-beryllium-status-ico_upd beryllium.dns-net-beryllium-status-ico_upd
}

proc beryllium.dns-net-beryllium-status-ico_clr {} {
global page_frame
set page_frame [window.create_statusbar_item]
    frame $page_frame -bd 0 -relief raised
    label $page_frame.mail -text "Mail" \
        -highlightthickness 0 -bg green -bd 1  -relief raised
    pack configure $page_frame.mail -side right
    pack $page_frame -side right
}


proc beryllium.do_dns_net_beryllium_status_msg_force {} {
    set which current
    catch { set which [request.get current _data-tag] }
    set text [request.get $which text]
    global cmd
    set cmd [request.get $which cmd]
    window.set_status $text
    bind .statusbar.messages <Double-ButtonRelease-1> {beryllium.command $cmd}
    after 20000 [set cmd ""]
}

proc beryllium.command cmd {
if { [string first "url:" $cmd] != 0 } {
   io.outgoing $cmd
 } elseif { [webbrowser.is_available] } {
    webbrowser.open [string range $cmd 4 end]
}
}

proc beryllium.blink on {
global mailstop
global page_frame
if {$mailstop == "y"} {
if { $on } {
    $page_frame.mail configure -fg green
    after 1000 beryllium.blink 0
    } {
    $page_frame.mail configure -fg black
    after 500 beryllium.blink 1
    }
    } {
    $page_frame.mail configure -fg black
    return;
    }
} 

proc beryllium.dns-net-beryllium-status-ico_upd {} {
    set which current
    catch { set which [request.get current _data-tag] }
    global hint
    set hint [request.get $which hint]
    global mailstop
    set mode [request.get $which mode]
    set mailstop "y"
    if {$mode == "blink"} {
    beryllium.blink 0
    set mailstop "y"
    } elseif {$mode == "normal"} {
    beryllium.blink 0
    set mailstop "n"
    }
}
proc beryllium.dns-net-beryllium-status-ico_add {} {
set which current
    catch { set which [request.get current _data-tag] }
    global mailcmd
    set mailcmd [request.get $which cmd]
    global hint
    set hint [request.get $which hint]
    global page_frame
    bind $page_frame.mail <ButtonRelease-3> {beryllium.set_status $hint}
    bind $page_frame.mail <Double-ButtonRelease-1> {beryllium.command $mailcmd}
    set_balloon $page_frame.mail "$hint"   
}

proc beryllium.set_status {text {type decay}} {
    global window_statusbar_current_task_id window_statusbar_message
    window.statusbar_create
    set window_statusbar_message $text
    window.statusbar_messages_repaint
    catch { 
    after cancel $window_statusbar_current_task_id 
    }
    if { $type == "decay" } {
    set window_statusbar_current_task_id [after 5000 window.statusbar_decay]
    }
}
