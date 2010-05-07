
#
#
#
client.register tkmootag start 60
client.register tkmootag client_connected
client.register tkmootag incoming
client.register tkmootag reconfigure_fonts


proc tkmootag.client_connected {} {
    global tkmootag_use tkmootag_lineTagList tkmootag_fixed

    set use [string tolower [worlds.get_generic on {} {} UseModuleTKMOOTAG]]
    if { $use == "on" } {
        set tkmootag_use 1
    } elseif { $use == "off" } {
        set tkmootag_use 0
    }

    set tkmootag_fixed 0

    set tkmootag_lineTagList {}

    tkmootag.reconfigure_fonts

    return [modules.module_deferred]
}

proc tkmootag.initialise_text_widget w {
    $w tag configure tkmootag_jtext_default -font [fonts.plain]
    $w tag configure tkmootag_header -font [fonts.header]
    $w tag configure tkmootag_header -foreground [colourdb.get darkgreen]
    $w tag configure tkmootag_bold -foreground [colourdb.get red]
    $w tag configure tkmootag_italic -foreground [colourdb.get orange]
    $w tag configure tkmootag_symbol -foreground [colourdb.get orange]
}

proc tkmootag.reconfigure_fonts {} {
    tkmootag.initialise_text_widget .output
    return [modules.module_deferred]
}

proc tkmootag.start {} {
    global tkmootag_use
    set tkmootag_use 1


    tkmootag.initialise_text_widget .output


    mcp21.register dns-com-awns-jtext 1.0 \
        dns-com-awns-jtext tkmootag.do_dns_com_awns_jtext
}

proc tkmootag.do_dns_com_awns_jtext {} {
}

proc tkmootag.incoming event {
    global tkmootag_use

    if { $tkmootag_use == 0 } {
        return [modules.module_deferred]
    }

    set line [db.get $event line]

    if { [string match {t*} $line] == 0 } {
        return [modules.module_deferred]
    }

    if { [regexp {^tkmootag: (.*)} $line throwaway msg] } {
	tkmootag.writeTextLine $msg .output {end - 1 chars}
        return [modules.module_ok]
    }

    return [modules.module_deferred]
}

#





proc tkmootag.car list { lindex $list 0 }
proc tkmootag.cdr list { concat [lrange $list 1 end] }

proc tkmootag.writeText {section t mark} {
  set tagName [tkmootag.car $section]
  if {[string index $tagName 0] == "~"} then {
    window.display "" {} $t
    set start [$t index $mark]
    window.display [string range $section 3 [expr [string length $section] - 2]] tkmootag_jtext_default $t
    return $start
  }
  set tagName [tkmootag.car [tkmootag.car $section]]
  return [tkmootag.writeText_$tagName [tkmootag.car $section] $t $mark]
}

proc tkmootag.writeText_bold {section t mark} {
  global tkmootag_lineTagList
  set start [tkmootag.writeText [tkmootag.cdr $section] $t $mark]
  lappend tkmootag_lineTagList [list tkmootag_bold $start [$t index $mark]]
  return $start
}

proc tkmootag.writeText_italic {section t mark} {
  global tkmootag_lineTagList
  set start [tkmootag.writeText [tkmootag.cdr $section] $t $mark]
  lappend tkmootag_lineTagList [list tkmootag_italic $start [$t index $mark]]
  return $start
}

proc tkmootag.writeText_header {section t mark} {
  global tkmootag_lineTagList
  set start [tkmootag.writeText [tkmootag.cdr $section] $t $mark]
  lappend tkmootag_lineTagList [list tkmootag_header $start [$t index $mark]]
  return $start
}

proc tkmootag.writeText_arrow {section t mark} {
  global tkmootag_lineTagList
  set start [$t index $mark]
  window.display "\254" {} $t
  lappend tkmootag_lineTagList [list tkmootag_symbol $start [$t index $mark]]
  return $start
}

proc tkmootag.writeText_link {section t mark} {
    global tkmootag_lineTagList

    set start [tkmootag.writeText [tkmootag.cdr [tkmootag.cdr $section]] $t $mark]
    set newTag [util.unique_id tkmootag]
    set callback [tkmootag.car [tkmootag.cdr $section]]



    regsub -all {\\} $callback "" callback

    window.hyperlink.link $t $newTag tkmootag.do_hyperlink
    $t tag bind $newTag <Leave> "+tkmootag.set_hyperlink_callback \"\""
    regsub -all { } $callback {\ } callback
    set callback [tkmootag.escape_tcl_meta $callback]
    $t tag bind $newTag <Enter> "+tkmootag.set_hyperlink_callback $callback"


    lappend tkmootag_lineTagList [list $newTag $start [$t index $mark]]

    return $start
}

proc tkmootag.escape_tcl_meta str {
    regsub -all {\$} $str {\\$} str
    return $str
}

proc tkmootag.do_hyperlink {} {
    global tkmootag_hyperlink_callback
    tkmootag.do_callback $tkmootag_hyperlink_callback
}

proc tkmootag.set_hyperlink_callback str {
    global tkmootag_hyperlink_callback
    set tkmootag_hyperlink_callback $str
}

proc tkmootag.do_callback str {
    global mcp_authentication_key

    set overlap [mcp21.report_overlap]
    set version [util.assoc $overlap dns-com-awns-jtext]
    if { ($version == {}) || ([lindex $version 1] == 1.0) } {
        set alist [tkmootag.to_alist $str]
        set type [lindex [util.assoc $alist address-type] 1]
        set args [lindex [util.assoc $alist args] 1]
        mcp21.server_notify dns-com-awns-jtext-pick [list [list type $type] [list args $args]]
	return
    }   

    if { [info exists mcp_authentication_key] &&
	 $mcp_authentication_key != "" } {
        io.outgoing "#$#jtext-pick $mcp_authentication_key $str"
    }
}

proc tkmootag.to_alist str {
    set alist {}
    foreach {keyword value} $str {
	regsub {:$} $keyword "" keyword
	lappend alist [list $keyword $value]
    }
    return $alist
}


proc tkmootag.writeText_hgroup {section t mark} {
  set start [$t index $mark]
  foreach hbox [lrange $section 1 end] {
    tkmootag.writeText [list $hbox] $t $mark
  }
  return $start
}

proc tkmootag.applyLineTagList t {
    global tkmootag_lineTagList
    foreach x $tkmootag_lineTagList {
        foreach tag [lindex $x 0] {
            $t tag add $tag [lindex $x 1] [lindex $x 2]
        }
    }
}

proc tkmootag.post_header {section t mark} {
    window.displayCR "" {} $t
}

proc tkmootag.writeTextLine {section t mark} {
  global tkmootag_lineTagList tkmootag_fixed
  set tkmootag_lineTagList {}
  tkmootag.writeText $section $t $mark
  tkmootag.applyLineTagList $t
  window.displayCR "" {} $t
  if { $tkmootag_fixed == 1 } {
      set tag [tkmootag.car [tkmootag.car $section]]
      catch { tkmootag.post_$tag $section $t $mark }
  }
}
#
#
