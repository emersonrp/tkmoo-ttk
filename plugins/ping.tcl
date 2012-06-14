#
#   tkMOO
#   ~/.tkMOO-lite/plugins/ping.tcl
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

#       Keep track of network connection latency.  This plugin creates
# a small 'volume indicator' which lights up LEDs according to just how
# slow the network connection is.  'slowness' is percieved as the time
# taken for the server to reply to a timestamped message.  Each LED
# represents 100ms delay -- if one LED is lit, the delay is <= 100ms, 
# two LEDs is <= 200ms, etc
# 
#    slowness = transfer time from server to client +
#               time taken by MOO to process request (this may be dependant
#               on how heavily your task queue is loaded).
#
# Comments:
# This is a pretty braindead way of indicating the network latency.  It
# might be better to send a message and then keep track of how long it is
# till you receive an answer.  The 'volume display' would then indicate
# the time on the waiting clock (which could be updated in milliseconds
# if you wanted).  This would give a much more accurate depiction of the
# latency.
# 
# The volume control metaphore is pretty handy.  It could be made into a
# mega widget so that you can define height/width, number of cells, cell
# colour etc.  Also the range of values that the cells respond to.

# we call mcp21.register_internal with is itself initialised with
# priority 50, we need to wait for it to be initialised.
client.register ping start 60
client.register ping client_connected 90
client.register ping client_disconnected

preferences.register ping {Statusbar Settings} {
    { {directive UsePing}
        {type boolean}
        {default Off}
        {display "Ping server"} }
} 

proc ping.start {} {
    global ping_frame
    set ping_frame 0
    catch {
        # register with the mcp21 plugin, if it exists...
        mcp21.register dns-com-awns-ping 1.0 \
            dns-com-awns-ping ping.do_dns_com_awns_ping
        mcp21.register dns-com-awns-ping 1.0 \
            dns-com-awns-ping-reply ping.do_dns_com_awns_ping_reply
        mcp21.register_internal ping mcp_negotiate_end

        # add an on/off function
        window.menu_tools_add "Ping on/off" ping.ping_toggle
        global ping_db
        set ping_db(active) 0
    }
    set ping_db(current) 0
}

proc ping.client_connected {} {
    set use [worlds.get_generic Off {} {} UsePing]
    if { [string tolower $use] == "on" } {
        ping.display 0
        ping.no_data
    }
    return [modules.module_deferred]
}

proc ping.mcp_negotiate_end {} {
    set use [worlds.get_generic Off {} {} UsePing]
    if { [string tolower $use] == "on" } {
        ping.ping_on
    }
}

proc ping.ping_toggle {} {
    global ping_db
    if { $ping_db(active) } {
        ping.ping_off
    } {
        ping.ping_on
    }
}

proc ping.ping_on {} {
    global ping_db
    if { $ping_db(active) } { 
        # already active
        return
    }
    set ping_db(active) 1
    # optional, the incoming reply will do this anyway
    ping.display 0
    ping.no_data
    ping.do
}

proc ping.do {} {
    global ping_db
    set id [util.unique_id p]
    set ping_db($id:time) [clock milliseconds]
    set ping_db(current) $id

    set overlap [mcp21.report_overlap]
    set version [util.assoc $overlap dns-com-awns-ping]
    if { ($version == {}) || ([lindex $version 1] == 1.0) } {
        mcp21.server_notify dns-com-awns-ping [list [list id $id]]
    }
}

proc ping.ping_off {} {
    global ping_db
    # unset will remove traces of any soon-to-arrive replys
    unset ping_db
    set ping_db(active) 0
    ping.destroy
}

proc ping.do_dns_com_awns_ping {} {
    set id [request.get current id]
    set overlap [mcp21.report_overlap]
    set version [util.assoc $overlap dns-com-awns-ping]
    if { ($version == {}) || ([lindex $version 1] == 1.0) } {
        mcp21.server_notify dns-com-awns-ping-reply [list [list id $id]]
    }
}

proc ping.do_dns_com_awns_ping_reply {} {
    global ping_db
    if { $ping_db(active) == 0 } {
        ping.destroy
        return
    }
    set id [request.get current id]

    if { $ping_db(current) != $id } {
        return
    }

    if { [info exists ping_db($id:time)] == 0 } { 
        return
    }

    set latency [expr [clock milliseconds] - $ping_db($id:time)]
    unset ping_db($id:time)
    set ping_db(current) 0

    ping.display $latency

    # ping again in 5 seconds
    after 5000 ping.do
}

proc ping.client_disconnected {} {
    global ping_frame
    ping.destroy
    return [modules.module_deferred]
}

proc ping.display latency {
    global ping_unlit ping_frame
    ping.create
    array set colour {
        1 green
        2 green
        3 green
        4 green
        5 green
        6 green
        7 orange
        8 orange
        9 orange
        10 red
    }
    for {set i 1} {($i < 11) && ($i <= ($latency/100)+1)} {incr i} {
        $ping_frame.r.$i configure -bg $colour($i)
    }
    for {} {$i < 11} {incr i} {
        $ping_frame.r.$i configure -bg $ping_unlit
    }
    set_balloon $ping_frame.r "$latency ms"
}

proc ping.create {} {
    global ping_unlit ping_frame
    if { [winfo exists $ping_frame] == 1 } { return }
    set ping_frame [window.create_statusbar_item]
    set f $ping_frame
    frame $f -bd 1 -relief raised -bg pink

    frame $f.r -bd 0 -highlightthickness 0 -bg pink
    pack $f.r -fill y -expand 1 -padx 2

    for {set i 1} {$i < 11} {incr i} {
        frame $f.r.$i \
            -bd 1 -highlightthickness 0 \
            -width 6 -height 10 -relief sunken \
            -bg pink
        pack configure $f.r.$i -side left
    }

    pack $f -fill y -expand 1

    set ping_unlit [$f.r.1 cget -bg]

    window.repack
}

proc ping.no_data {} {
    global ping_frame
    set f $ping_frame
    set grey [. cget -bg]
    for {set i 1} {$i < 11} {incr i} {
        $f.r.$i configure -bg $grey
    }
}

proc ping.destroy {} {
    global ping_frame
    global ping_db
    set ping_db(active) 0
    catch { window.delete_statusbar_item $ping_frame }
}

proc ping.ping {} {
    global ping_frame
    if { [winfo exists $ping_frame] == 0 } { return }
    io.outgoing "ping [clock milliseconds]"
    after 5000 ping.ping
}

