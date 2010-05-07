
client.register mcp start
client.register mcp client_connected
client.register mcp incoming



#
#
#
#
#
#
#

proc mcp.client_connected {} {
    global mcp_log mcp_use mcp_use_log mcp_active mcp_authentication_key

    set mcp_authentication_key ""

    request.set current mcp_multiline_procedure ""
    request.set current mcp_lines ""

    set use [string tolower [worlds.get_generic off {} {} UseModuleMCP]]

    if { $use == "on" } {   
        set mcp_use 1
    } elseif { $use == "off" } {
        set mcp_use 0
    }
    ###

    set mcp_active 0

    set mcp_use_log 0
    return [modules.module_deferred]
}

proc mcp.start {} {
    global mcp_use mcp_use_log
    set mcp_use 1
    set mcp_use_log 0
    ###
    .output tag configure mcp_mcp	-foreground [colourdb.get darkgreen]
    .output tag configure mcp_type	-foreground [colourdb.get red]
    .output tag configure mcp_value	-foreground [colourdb.get blue]
    .output tag configure mcp_default

    preferences.register mcp {Out of Band} {
        { {directive UseModuleMCP} 
            {type boolean}
            {default Off}
            {display "Use MCP/1.0"} }
    }   
}


proc mcp.logCR { line tag io } { 
    global mcp_log mcp_use_log 

    if { $mcp_use_log == 0 } {
	return
    }
    window.displayCR $line $tag
}

proc mcp.log { line tag io } { 
    global mcp_log mcp_use_log 

    if { $mcp_use_log == 0 } {
	return
    }
    window.display $line $tag
}

proc mcp.incoming event {
    global mcp_log mcp_use mcp_active


    if { $mcp_use == 0 } {
        return [modules.module_deferred]
    }

    set line [db.get $event line]

    if { ([string match {#*} $line] == 0) && 
	 ([string match {@*} $line] == 0) } {
        return [modules.module_deferred]
    }

    if { [regexp {^#\$#([-a-zA-Z0-9*]*) *(.*)} $line throwaway type rest] } {


        if { ($type != "mcp") && ($mcp_active == 0) } {
            return [modules.module_deferred]
	}

        mcp.log "#$#" mcp_mcp "<"
        mcp.log "$type " mcp_type ""
        if { [mcp.parse $rest] } {
            catch mcp.do_$type
        }
        set last [string index $type [expr [string length $type] - 1]]
        if { $last == "*" } {
	    request.set current mcp_lines ""
	    ###
	    catch {
	    if { [set tag [request.get current tag]] } {
		request.duplicate current $tag
	    }
	    }
	    #
	    ###
	} {
            mcp.unset_header
        }
        return [modules.module_ok]
    }

    if { [regexp {^@@@(.*)} $line throwaway tail] } {
        if { [request.get current mcp_multiline_procedure] != "" } {
            mcp.log "@@@" mcp_mcp "<"
            mcp.logCR "$tail" mcp_default ""
            request.set current mcp_lines [concat [request.get current mcp_lines] [list $tail]]
            return [modules.module_ok]
        }
    }

    return [modules.module_deferred]
}

proc mcp.parse header {
    set first [lindex $header 0]
    if {![regexp ":" $first]} {
	request.set current _authentication-key $first
        mcp.log "$first " mcp_mcp ""
        set header [lrange $header 1 end]
    } {
	request.set current _authentication-key NULL
    }

    set keyword ""
    foreach item $header {
        if { $keyword != "" } {
	    request.set current $keyword $item
            mcp.log "$keyword: " mcp_mcp ""
            mcp.log "$item " mcp_value ""
            set keyword ""
        } {
            set keyword $item
            regsub ":" $keyword "" keyword
        }
    }
    mcp.logCR "" mcp_default ""
    return 1
}

proc mcp.authenticated {} {
    global mcp_authentication_key 
    if { [request.get current _authentication-key] == $mcp_authentication_key } {
        return 1
    }
    return 0
}

###
proc mcp.unset_header {} {
    request.destroy current

    request.set current mcp_multiline_procedure ""
    request.set current mcp_lines ""
}

###
###

proc mcp.do_mcp {} {
    global mcp_authentication_key mcp_active

    if { [request.get current version] == "1.0" } {
        scan [winfo id .] "0x%x" mcp_authentication_key
        io.outgoing "#$#authentication-key $mcp_authentication_key"
        mcp.log "#$#" mcp_mcp ">"
        mcp.log "authentication-key " mcp_method ""
        mcp.logCR "$mcp_authentication_key" mcp_value ""
	set mcp_active 1
    }
}

proc mcp.do_data {} {
    set tag [request.get current tag]
    request.set $tag mcp_lines [concat [request.get $tag mcp_lines] [list [request.get current data]]]
}

proc mcp.do_END {} {
    set which current
    catch {
    set which [request.get current tag]
    }
    if { [request.get $which mcp_multiline_procedure] != "" } {
	request.set $which _lines [request.get $which mcp_lines]
	mcp.do_callback_[request.get $which mcp_multiline_procedure]
    }
    request.destroy $which
}

###


proc mcp.controls {} {
    return {"MCP/1.0" "mcp.callback"}
}

proc mcp.callback {} {
    set c .modules_mcp_controlpanel
    catch { destroy $c }

    toplevel $c

    window.place_nice $c

    $c configure -bd 0

    wm title    $c "MCP/1.0 Control Panel"
    wm iconname $c "MCP/1.0"

    frame $c.buttons

    checkbutton $c.buttons.usemcp \
	-padx 0 \
        -text "use mcp" \
        -variable mcp_use

    checkbutton $c.buttons.mcpactive \
	-padx 0 \
        -text "mcp active" \
        -variable mcp_active

    checkbutton $c.buttons.uselog \
	-padx 0 \
        -text "log mcp" \
        -variable mcp_use_log

    button $c.buttons.close \
        -text "Close" \
        -command "destroy $c";
 
    pack append $c.buttons \
        $c.buttons.usemcp	{left padx 4} \
        $c.buttons.mcpactive	{left padx 4} \
        $c.buttons.uselog	{left padx 4} \
        $c.buttons.close	{left padx 4}

    pack append $c \
        $c.buttons {fillx pady 4}
}
#
#


proc mcp.do_edit* {} {
    if { [mcp.authenticated] == 1 } {
        request.set current mcp_multiline_procedure "edit*"
    }
}

proc mcp.do_callback_edit* {} {
    set which [request.current]
    
    set pre [request.get $which upload]
    set lines [request.get $which _lines]
    set post "."

    set title [request.get $which name]
    set icon_title [request.get $which name]

    edit.SCedit $pre $lines $post $title $icon_title
}
#
#

###                     
#
#
#
####

proc mcp.do_display-url {} {
    set netscape "netscape"

    if { [mcp.authenticated] == 1 } {
        set url [request.get current url]
        set xwin ""
        catch { set xwin [request.get current xwin] }
        if { $xwin != "" } {
            exec "$netscape" "-id $mcp_header(xwin) -noraise -remote openURL($ur
l)" &
        } {
            exec "$netscape" "-remote openURL($url)" &
        }
    }
}

#
#
