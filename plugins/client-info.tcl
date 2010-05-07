#
#       tkMOO
#       ~/.tkMOO-lite/plugins/client-info.tcl
#	*** ALFA VERSION *** come here often !!!
#
#       v0.8
#        
#	This plugin implements the package "dns-com-vmoo-client" with
#	the following messages:
#
#		dns-com-vmoo-client-info
#
#	It's missing "dns-com-vmoo-client-disconnect"
#
#	http://www.vmoo.com/support/moo/mcp-specs/#vgm-client
#

client.register clientinfo start 55
client.register clientinfo client_disconnected

variable ocols 80
variable orows 24
variable disconn {}

proc clientinfo.start {} {
    mcp21.register dns-com-vmoo-client 1.0 \
        dns-com-vmoo-client-info clientinfo.info 
    mcp21.register dns-com-vmoo-client 1.0 \
        dns-com-vmoo-client-screensize clientinfo.screensize
    mcp21.register dns-com-vmoo-client 1.0 \
        dns-com-vmoo-client-disconnect clientinfo.disconnect
    mcp21.register_internal clientinfo mcp_negotiate_end
    # update moo with client geometry
    clientinfo.screensize
    # last stuff
    bind . <Configure> { clientinfo.screensize }
}

proc clientinfo.info {} {
  # do nothing
}

proc clientinfo.screensize {} {
    global ocols orows
    set actual_geometry [winfo geometry .output]
    regexp {([0-9]+)x([0-9]+)} $actual_geometry \
        match cols rows
    set cols [expr $cols / 7]
    if { [plusminus $ocols $cols] != 1 || [plusminus $orows $rows] != 1} {
        set ocols $cols
        set orows $rows
        mcp21.server_notify dns-com-vmoo-client-screensize [list [list cols $cols] [list rows $rows] ]
    }
}

proc clientinfo.mcp_negotiate_end {} {
    global ocols
    set overlap [mcp21.report_overlap]
    set version [util.assoc $overlap dns-com-vmoo-client]
    set tkmooversion [util.version]
    if { ($version != {}) && ([lindex $version 1] == 1.0) } {
       mcp21.server_notify dns-com-vmoo-client-info [list [list name tkMOO-light] [list text-version "$tkmooversion" ] [list internal-version 0] ]
       #set ocols 1
    }
## clientinfo.screensize
    global ocols orows
    set actual_geometry [wm geometry .]
    regexp {([0-9]+)x([0-9]+)} $actual_geometry \
        match cols rows
        set cols [expr $cols / 7]
        set ocols $cols
        set orows $rows
        mcp21.server_notify dns-com-vmoo-client-screensize [list [list cols $cols] [list rows $rows] ]
}

proc plusminus {x y} {
set z [expr {$x == $y-1 || $x == $y+1}]
expr {$z || $x == $y}
}

proc clientinfo.disconnect {} {
     global disconn
     set which current
     catch { set which [request.get current _data-tag] }
     catch { set reason [request.get $which reason] }
     set disconn [list $reason [clock seconds]]
}

proc clientinfo.client_disconnected {} {
     global disconn
     if {$disconn != {}} {
     set dtime [lindex $disconn 1]
     set reason [lindex $disconn 0]
     set time [clock seconds]
     set t [expr $time - $dtime]
     window.displayCR $t
     if {$t > 5 && $reason != ""} {
     window.display "CLIENT DISCONNECTED: $reason"
     }}
     set disconn {}
}