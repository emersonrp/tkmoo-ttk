
client.register xmcp11 start
client.register xmcp11 client_connected
client.register xmcp11 incoming

proc xmcp11.client_connected {} {
    global xmcp11_use xmcp11_use_log xmcp11_authentication_key xmcp11_active

    request.set current xmcp11_multiline_procedure ""
    request.set current xmcp11_lines ""

    set use [string tolower [worlds.get_generic on {} {} UseModuleXMCP11]]

    if { $use == "on" } {
        set xmcp11_use 1
    } elseif { $use == "off" } {
        set xmcp11_use 0
    }
    ###

    set xmcp11_active 0

    set xmcp11_use_log 0
    set xmcp11_authentication_key ""
    return [modules.module_deferred]
}

proc xmcp11.start {} {
    global xmcp11_use
    set xmcp11_use 0
    ###
    .output tag configure xmcp11_mcp	-foreground [colourdb.get darkgreen]
    .output tag configure xmcp11_type	-foreground [colourdb.get red]
    .output tag configure xmcp11_value	-foreground [colourdb.get blue]
    .output tag configure xmcp11_default
    window.menu_tools_add "@xmcp_challenge"  {io.outgoing {@xmcp_challenge}}
}

proc xmcp11.logCR { line tag io } { 
    global xmcp11_use_log 

    if { $xmcp11_use_log == 0 } {
	return
    }
    window.displayCR $line $tag
}

proc xmcp11.log { line tag io } { 
    global xmcp11_use_log 

    if { $xmcp11_use_log == 0 } {
	return
    }
    window.display $line $tag
}

proc xmcp11.incoming event {
    global xmcp11_use xmcp11_active

    if { $xmcp11_use == 0 } {
        return [modules.module_deferred]
    }

    set line [db.get $event line]

    if { [string match {\$*} $line] == 0 } {
        return [modules.module_deferred]
    }

    if { [regexp {^\$#\$([-a-zA-Z0-9*]*) *(.*)} $line throwaway type rest] } {


        if { ($type != "xmcp") && ($xmcp11_active == 0) } {
	    return [modules.module_deferred]
	}

        xmcp11.log "\$#\$" xmcp11_mcp "<"
        xmcp11.log "$type " xmcp11_type ""
	request.set current _type $type
        if { [xmcp11.parse $rest] } {
            if { [info procs "xmcp11.do_$type"] != {} } {
                xmcp11.do_$type
            } {
                return [modules.module_deferred]
            }
        }
        set last [string index $type [expr [string length $type] - 1]]
        if { $last == "*" } {
	    request.set current xmcp11_lines ""
	    ###
	    catch {
	    if { [set tag [request.get current tag]] } {
		request.duplicate current $tag
	    }
	    }
	    #
	    ###
	} {
            xmcp11.unset_header
        }
        return [modules.module_ok]
    }

    return [modules.module_deferred]
}

proc xmcp11.parse header {
    set first [lindex $header 0]
    if {![regexp ":" $first]} {
	request.set current _authentication-key $first
        xmcp11.log "$first " xmcp11_mcp ""
        set header [lrange $header 1 end]
    } {
	request.set current _authentication-key NULL
    }

    set keyword ""
    foreach item $header {
        if { $keyword != "" } {
	    request.set current $keyword $item
            xmcp11.log "$keyword: " xmcp11_mcp ""
            xmcp11.log "$item " xmcp11_value ""
            set keyword ""
        } {
            set keyword $item
            regsub ":" $keyword "" keyword
        }
    }
    xmcp11.logCR "" xmcp11_default ""
    return 1
}



proc xmcp11.authenticated { {flag verbose} } {
    global xmcp11_authentication_key 
    if { [request.get current _authentication-key] == $xmcp11_authentication_key } {
        return 1
    }
    if { $flag == "verbose" } {
        xmcp11.no_auth_dialog [request.get current _type] [request.get current _authentication-key]
    }
    return 0
}

proc xmcp11.no_auth_dialog { message key } {
    tk_dialog .xmcp11_no_auth_dialog "XMCP/1.1 Authentication Error" \
        "XMCP/1.1 message '$message' not authenticated by key '$key'.  Message ignored." \
        info 0 OK
}

###
proc xmcp11.unset_header {} {
    request.destroy current

    request.set current xmcp11_multiline_procedure ""
    request.set current xmcp11_lines ""
}

proc xmcp11.do_xmcp {} {
    global xmcp11_authentication_key xmcp11_active

    set authenticate "@xmcp_authentication_key"

    if { [request.get current version] == "1.1" } {
        scan [winfo id .] "0x%x" xmcp11_authentication_key
        io.outgoing "$authenticate $xmcp11_authentication_key"
        xmcp11.log "$#$" xmcp11_mcp ">"
        xmcp11.log "$authenticate " xmcp11_method ""
        xmcp11.logCR "$xmcp11_authentication_key" xmcp11_value ""

	set xmcp11_active 1


        set xscript ""
        catch { set xscript [worlds.get [worlds.get_current] XMCP11_AfterAuth] }
        if { $xscript != "" } {
            io.outgoing $xscript
        }
    }
}

proc xmcp11.do_data {} {

    set tag [request.get current tag]
    set lines "NOLINES"
    catch { set lines [request.get $tag xmcp11_lines] }
    if { $lines == "NOLINES" } {
    } {
    request.set $tag xmcp11_lines [concat $lines [list [request.get current data]]]
    }
}

proc xmcp11.do_END {} {
    set which current
    catch { set which [request.get current tag] }
    catch {
        set callback [request.get $which xmcp11_multiline_procedure]
        if { $callback != "" } {
	    request.set $which _lines [request.get $which xmcp11_lines]
            if { [info procs "xmcp11.do_callback_$callback"] != {} } {
                xmcp11.do_callback_$callback
            }
        }
    }
    request.destroy $which
}

###


proc xmcp11.controls {} {
    return {"XMCP/1.1" "xmcp11.callback"}
}

proc xmcp11.callback {} {
    set c .modules_xmcp11_controlpanel
    catch { destroy $c }

    toplevel $c

    window.place_nice $c

    $c configure -bd 0

    wm title    $c "XMCP/1.1 Control Panel"
    wm iconname $c "XMCP/1.1"

    frame $c.buttons

    checkbutton $c.buttons.usemcp \
	-padx 0 \
        -text "use xmcp/1.1" \
        -variable xmcp11_use

    checkbutton $c.buttons.xmcp11active \
	-padx 0 \
        -text "xmcp/1.1 active" \
        -variable xmcp11_active

    checkbutton $c.buttons.uselog \
	-padx 0 \
        -text "log xmcp/1.1" \
        -variable xmcp11_use_log

    button $c.buttons.close \
        -text "Close" \
        -command "destroy $c";
 
    pack append $c.buttons \
        $c.buttons.usemcp	{left padx 4} \
        $c.buttons.xmcp11active	{left padx 4} \
        $c.buttons.uselog	{left padx 4} \
        $c.buttons.close	{left padx 4}

    pack append $c \
        $c.buttons {fillx pady 4}
}
#
#
