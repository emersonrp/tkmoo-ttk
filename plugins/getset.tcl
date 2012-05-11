#
#    tkMOO
#    ~/.tkMOO-lite/plugins/getset.tcl
#

# tkMOO-light is Copyright (c) Andrew Wilson 1994,1995,1996,1997,1998
#
#       All Rights Reserved
#
# Permission is hereby granted to use this software for private, academic
# and non-commercial use. No commercial or profitable use of this
# software may be made without the prior permission of the author.
#
# THIS SOFTWARE IS PROVIDED BY ANDREW WILSON ``AS IS'' AND ANY
# EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL ANDREW WILSON BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# dns-com-awns-getset
# a set of messages which allow the client to store, retrieve and
# erase information held on the server.  information is held server-side
# in an associative array (possibly a list structure, but other
# server-side implementations are possible).

# C->S get id property
# C->S set id property value
# C->S drop id property
#
# S->C ack id <any number of undefined key-vals>

# Contains an example notepad application.  Invoked from
# Tools->GetSetDrop menu item

client.register getset start

proc getset.start {} {
    mcp21.register dns-com-awns-getset 1.0 \
            dns-com-awns-getset-get getset.do_dns_com_awns_getset_get
    mcp21.register dns-com-awns-getset 1.0 \
            dns-com-awns-getset-set getset.do_dns_com_awns_getset_set
    mcp21.register dns-com-awns-getset 1.0 \
            dns-com-awns-getset-ack getset.do_dns_com_awns_getset_ack
    window.menu_tools_add "GetSetDrop" getset_app.create
}

proc getset.do_dns_com_awns_getset_get {} {
    # client-side this is a no-op
}

proc getset.do_dns_com_awns_getset_set {} {
    # client-side this is a no-op
}

proc getset.do_dns_com_awns_getset_ack {} {
    global getset_db
    set id [request.get current id]
    if { [info exists getset_db($id,callback)] } {
        $getset_db($id,callback)
        unset getset_db($id,callback)
    }
}

# .get => {}
#         {value}
proc getset.get {property {callback ""}} {
    global getset_db
    set id [util.unique_id getset]
    if { $callback != "" } {
        set getset_db($id,callback) $callback
    }
    mcp21.server_notify dns-com-awns-getset-get \
    [list [list id "$id"] [list property "$property"]]
}

# .set => {}
proc getset.set {property value {callback ""}} {
    global getset_db
    set id [util.unique_id getset]
    if { $callback != "" } {
        set getset_db($id,callback) $callback
    }
    mcp21.server_notify dns-com-awns-getset-set \
    [list [list id "$id"] [list property "$property"] [list value "$value"]]
}

# .drop => {}
proc getset.drop {property {callback ""}} {
    global getset_db
    set id [util.unique_id getset]
    if { $callback != "" } {
        set getset_db($id,callback) $callback
    }
    mcp21.server_notify dns-com-awns-getset-drop \
    [list [list id "$id"] [list property "$property"]]
}

# --------------------------------------------------------------------------
# toy application to test the messages.  a simple dialog box containing
# a text widget and buttons for [get] [set] [drop]

proc getset_app.create {} {
    set w .getsetapp
    catch { destroy .getsetapp }
    toplevel $w
    text $w.t -width 30 -height 10
    ttk::frame $w.f
    ttk::button $w.f.get -width 4 -text get -command getset_app.do_get
    ttk::button $w.f.set -width 4 -text set -command getset_app.do_set
    ttk::button $w.f.drop -width 4 -text drop -command getset_app.do_drop
    pack $w.t -side top
    pack $w.f -side bottom
    pack $w.f.get -side left
    pack $w.f.set -side left
    pack $w.f.drop -side left
}

proc getset_app.do_get {} {
    getset.get getset_app.text getset_app.do_get_ack
}

proc getset_app.do_set {} {
    set value [getset_app.get_text .getsetapp.t]
    getset.set getset_app.text "$value" getset_app.do_ack
}

proc getset_app.do_ack {} {
    window.displayCR "getset_app.do_ack"
}

proc getset_app.do_get_ack {} {
    set value [request.get current value]
    .getsetapp.t delete 1.0 end
    getset_app.set_text .getsetapp.t $value
}

proc getset_app.do_drop {} {
    getset.drop getset_app.text getset_app.do_ack
}

proc getset_app.get_text t {
    set lines {}
    set last [$t index end]
    for {set n 1} {$n < $last} {incr n} {
        set line [$t get "$n.0" "$n.0 lineend"]
        lappend lines $line
    }
    return $lines
}

proc getset_app.set_text { t lines } {
    set CR ""
    foreach line $lines {
        $t insert end "$CR$line"
        set CR "\n"
    }
}
