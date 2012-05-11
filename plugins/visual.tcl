tk::unsupported::ExposePrivateCommand *
#
#    tkMOO
#    visual.tcl
#

# $Id: visual.tcl,v 1.1 2010/05/07 12:28:51 emerson Exp $

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

#       maintain a database of cached information.  used to support
#    the buddy list, map and compass-based navigation systems in the
#    client.

# TODO
# 
# We need to be able to pass parameters to .dispatched-to procedures
# for C->S requests like get_topology.  Topology takes arguments:
# $location $distance

# API
# 
# Installation
#
# Well really, "how Visual interprets the client's own special
# events".  We may as well keep it simple and make sure that Visual
# scrubs its state before (and after?) every connection.
# 
#     visual.client_connected
#
# Registration
#
# Visual assumes that it's applications are event driven.  Either
# through the UI or from events received from the server.  Suppose
# the server sends some new information every 60 seconds.  Visual
# synthesises an event based on the nature of the new information
# received and dispatches it to any applications that want to receive
# it.
# 
#     visual.register
#     visual.dispatch
#
# Internal Events
#
# Visual synthesises a range of events which it'll dispatch to the
# dependant applications.  The following events are supported:
#
# update_topology
#
#    some part of Visual's topology database has been updated.
#    dependent applications should supply a callback procedure which
#    handles this.  for example they may decide to redraw the
#    connectivity of rooms in a map, or add or remove rooms.
#
# update_users
# 
#    some part of Visual's user database has been updated.  new
#    users may have been added or removed, or the users' idle times
#    or locations or names may have been changed.  dependent
#    applications may choose to redraw a who list, resorting user
#    names based on their idle-time or present locations.
#
# update_location
#
#    the user's location has changed.  applications can assume that
#    this means that the user has moved to another room in the MUD
#    or that some analogous operation has been performed.  dependent
#    applications may choose to redraw the map or rose widget from
#    the new perspective.
#
# update_self
#
#    the user's unique id has changed.  this might more normally be
#    interpreted as meaning 'the user we're interesting in has
#    changed'.  i don't currently have any apps that would assume
#    this id is anything other then that of the current connection.
#    eg: the player's object.
#
# Database API
#
#    information will be arriving from the server via OOB protocols
#    like MCP/2.1 or XMCP/1.1.  the Database API defines how to tell
#    Visual about this new data.
#
# Query API
#
#    client-side applications will want to query Visual's database.
#    the Query API defines the questions that applications can ask,
#    and what the answers look like.
#
#    visual.get_location $id
#        $id = "" implies 'you'
#
#    visual.get_topology $location $distance
#        return the topology reachable $distance rooms from $location
#
#    visual.get_location
#        return the current location, where you are
#
#    visual.get_self
#        return the identifier for the current object, who you are
#
# Request API
#
#    ***
#    *** this isn't worked out fully yet...
#    ***
#
#    queries from applications may sometimes require Visual to ask
#    the server for more information.  applications should supply
#    callbacks, via the visual.register API call which support
#    Visual's requests.
#
#    what we're doing here is asking packages to provide wrappers
#    for visual to use so that visual can talk to the server.  so
#    an mcp/2.1 package might provide some code that can wrap up
#    the request into mcp/2.1ese and send it to the server.  the
#    replies if any, will be sent by the server, when it feels the
#    need and will be handled by other procedures whcih are also
#    set up to use the .request/.dispatch routines.
#
#    Callbacks should detect whether or not they are activated (by
#    detecting UseWhatever).  We don't want XMCP/1.1 to fire a
#    request after MCP/2.1 has already done the job.
#
# events include:
#
# get_self
#
#    Visual needs to know who you are.  The callback should phrase
#    this in some OOB dialect.  The server should then promptly
#    return information to the client.
#
# get_location
#
#    Visual needs to know where $userid's location is (V doesn't
#    know already, or anticipates that the value may have changed).
#    The callback should phrase this in some OOB dialect.  The server
#    should then promptly return information to the client.
#
#        implies $callback $userid
#        $id = "" implies 'you'
#
# get_topology 
#
#    Visual needs to know the topology, up to a given depth from an
#    initial location.  The server should supply at least that much
#    available topology and perhaps more if bandwidth permits.
#    The callback should phrase this in some OOB dialect.
#
#        implies $callback $locationid $depth
#
# get_users
#
#    Visual needs to know who's online.  The server should send
#    this information promptly.
#
# S->C API
#
#    information will arrive from the server via some OOB dialect.
#    the OOB handler must unparse the information it received and
#    call one of the following visual.* API procedures to inform
#    Visual about the new information:
#
#    visual.update_self $id
#        your useridentifier is $id
#
#    visual.update_location $locationid
#        user 'you' is at location with id $locationid
#
#    visual.update_topology
#
#    topology is a list of location records.  each location record
#    is an id, a human readable name (like "The Sandy Beach") and
#    a list of exit records.  each ecit record consists of a
#    direction specifier (one of the cardinal points 'n','s', etc)
#    and a location id denoting the location reachable in that
#    direction.  visual.update_topology takes a single parameter
#    that looks like this:
#
#        { 
#            {$location $name
#             {
#                 {$direction1 $location1}
#                 {$direction2 $location2}
#                 ....
#             }
#            }
#            ...
#        }
#
#    the information overlays existing information, allowing us to
#    build up a map of the MOOs surface.  Visual's topology database
#    (along with all other information) can be erased by calling
#    visual.init.  it probably shouldn't be called other than via
#    visual.client_connected or by explicit calls from the widgets
#    that form the GUI
#
# visual.update_users
#
#    users is a list of user records.  each user record is a list
#    containing the id of a user, a human readable name (eg
#    "Networker"), a location's id and the value in seconds that
#    this user has been idle.  visual.update_users takes a single
#    parameter that looks like this:
#
#    {
#        {$id1 $name1 $locationid1 $idle1}
#        {$id2 $name2 $locationid2 $idle2}
#        ...
#    }

# MCP/2.1 dns-com-awns-visual
# This code is present for the sake of testing only.  It should
# really be present in a separate plugin.

# we call mcp21.register_internal which is itself initialised with 
# priority 50, we need to wait for it to be initialised.
client.register visual start 60
client.register visual client_connected

proc visual.start {} {
    global visual_registry
    if { [info exists visual_registry] == 0 } {
        set visual_registry {}
    }
    mcp21.register dns-com-awns-visual 1.0 \
        dns-com-awns-visual-users visual.do_dns_com_awns_visual_users
    mcp21.register dns-com-awns-visual 1.0 \
        dns-com-awns-visual-topology visual.do_dns_com_awns_visual_topology
    mcp21.register dns-com-awns-visual 1.0 \
        dns-com-awns-visual-location visual.do_dns_com_awns_visual_location
    mcp21.register dns-com-awns-visual 1.0 \
        dns-com-awns-visual-self visual.do_dns_com_awns_visual_self
    mcp21.register_internal visual mcp_negotiate_end
    visual.register visual.mcp21 get_self
    visual.register visual.mcp21 get_topology
    visual.register visual.mcp21 get_location
    visual.register visual.mcp21 get_users
    visual.init
    edittriggers.register_alias visual.macro_self visual.macro_self
    edittriggers.register_alias visual.macro_location visual.macro_location
    edittriggers.register_alias visual.macro_users visual.macro_users
    edittriggers.register_alias visual.macro_topology visual.macro_topology
}

# load some information into visual when the negotiation phase is complete
# get_self will invoke mcp21 messages
proc visual.mcp_negotiate_end {} {
    visual.get_self
}

# ---------------------------------------------------------------------
# MCP/2.1 stuff...
proc visual.do_dns_com_awns_visual_users {} {
    set which current
    catch { set which [request.get current _data-tag] }
    # 4 long lists, we need to splice them...
    set id [request.get $which id]
    # EDIT: added code to remove any ansi code
    set name [ansi.remove_tags [request.get $which name]]
    set location [ansi.remove_tags [request.get $which location]]
    set idle [request.get $which idle]
    set users {}
    set len [llength $id]
    for {set i 0} {$i < $len} {incr i} {
    set record [list [lindex $id $i] [lindex $name $i] [lindex $location $i] [lindex $idle $i]]
    lappend users $record
    }
    visual.update_users $users
}

proc visual.do_dns_com_awns_visual_topology {} {
    set which current
    catch { set which [request.get current _data-tag] }
    set id [request.get $which id]
    # EDIT: added code to remove any ansi code
    set name [ansi.remove_tags [request.get $which name]]
    set exit [request.get $which exit]
    set topology {}
    set len [llength $id]
    for {set i 0} {$i < $len} {incr i} {
    set the_id [lindex $id $i]
    set the_name [lindex $name $i]
    set the_exits [lindex $exit $i]
    set the_exits_list {}
    foreach {direction roomid} $the_exits {
        lappend the_exits_list [list $direction $roomid]
    }
    set record [list $the_id $the_name $the_exits_list]
    lappend topology $record
    }
    visual.update_topology $topology
}

proc visual.do_dns_com_awns_visual_location {} {
    set id [request.get current id]
    visual.update_location $id
}

proc visual.do_dns_com_awns_visual_self {} {
    set id [request.get current id]
    visual.update_self $id
}
# ---------------------------------------------------------------------

proc visual.client_connected {} {
    visual.init
    return [modules.module_deferred]
}

proc visual.init {} {
    global visual_db
    set visual_db(users) {}
    set visual_db(topology) {}
    set visual_db(location) ""
    set visual_db(self) ""
}

# notify dependant applications that something has changed inside
# visual

proc visual.register { module event } {
    global visual_registry
    lappend visual_registry [list $module $event]
}

proc visual.dispatch { event args } {
    global visual_registry
    foreach me $visual_registry {
    if { $event == [lindex $me 1] } {
        eval [lindex $me 0].$event $args
    }
    }
}

# --------------------------------------------------------------------------
# QUERY API
#
# return any values in the db.  if there's nothing there then
# consider asking the server for an update.

# right now we're calling mcp21 directly, we should instead dispatch
# a get_ event and have registered handlers deal with it.

proc visual.macro_self {} {
    set overlap [mcp21.report_overlap]
    set version [util.assoc $overlap dns-com-awns-visual]
    if { ($version == {}) || ([lindex $version 1] != 1.0) } {
        return
    }
    mcp21.server_notify dns-com-awns-visual-getself
}


proc visual.macro_location {} {
    set overlap [mcp21.report_overlap]
    set version [util.assoc $overlap dns-com-awns-visual]
    if { ($version == {}) || ([lindex $version 1] != 1.0) } {
        return
    }
    mcp21.server_notify dns-com-awns-visual-getlocation
}

proc visual.macro_users {} {
    set overlap [mcp21.report_overlap]
    set version [util.assoc $overlap dns-com-awns-visual]
    if { ($version == {}) || ([lindex $version 1] != 1.0) } {
        return
    }
    mcp21.server_notify dns-com-awns-visual-getusers
}

proc visual.macro_topology {} {
    set overlap [mcp21.report_overlap]
    set version [util.assoc $overlap dns-com-awns-visual]
    if { ($version == {}) || ([lindex $version 1] != 1.0) } {
        return
    }
    set location [visual.get_location]
    if { $location != "" } {
        mcp21.server_notify dns-com-awns-visual-gettopology [list [list location $location] [list distance 1]]
    }
}

proc visual.get_self {} {
    global visual_db
    if { $visual_db(self) == "" } {
    # someone please get me this information...
    visual.dispatch get_self
    }
    return $visual_db(self)
}

proc visual.mcp21.get_self {} {
    set overlap [mcp21.report_overlap]
    set version [util.assoc $overlap dns-com-awns-visual]
    if { ($version == {}) || ([lindex $version 1] != 1.0) } {
        return 0
    }
    mcp21.server_notify dns-com-awns-visual-getself
    return 1
}

# FIXME
# i don't think we need to worry about this any more.  if you want
# to know the location of someone then look it up in the list of
# users...  so remove the 'who' argument
proc visual.get_location { {who ""} } {
    global visual_db
    if { $who == "" } {
    if { $visual_db(location) == "" } {
        visual.dispatch get_location
    }
        return $visual_db(location)
    }
    # return the user's location
    set user_record [util.assoc $visual_db(users) $who]
    if { $user_record == {} } {
    return ""
    }
    return [lindex $user_record 2]
}

proc visual.mcp21.get_location {} {
    set overlap [mcp21.report_overlap]
    set version [util.assoc $overlap dns-com-awns-visual]
    if { ($version == {}) || ([lindex $version 1] != 1.0) } {
    return 0
    }
    mcp21.server_notify dns-com-awns-visual-getlocation
    return 1
}

# return a list of room records
proc visual.get_topology { location distance } {
    global visual_db
    # make a traversable data structure
    foreach record $visual_db(topology) {
    set tmp([lindex $record 0]) [lrange $record 1 end]
    }
    # start at a given location traverse up to $distance hops from there
    # stub assumes distance = 1
    set available ""
    catch { set available $tmp($location) }
    if { $available != "" } {
        return [list [concat [list $location] $tmp($location)]]
    } {
    visual.dispatch get_topology $location $distance
    return [list]
    }
}

proc visual.mcp21.get_topology {location distance} {
    set overlap [mcp21.report_overlap]
    set version [util.assoc $overlap dns-com-awns-visual]
    if { ($version == {}) || ([lindex $version 1] != 1.0) } {
    return 0
    }
    mcp21.server_notify dns-com-awns-visual-gettopology [list [list location $location] [list distance $distance]]
    return 1
}

# return a list of users
proc visual.get_users {} {
    global visual_db
    if { $visual_db(users) == {} } {
    visual.dispatch get_users
    }
    return $visual_db(users)
}

proc visual.mcp21.get_users {} {
    set overlap [mcp21.report_overlap]
    set version [util.assoc $overlap dns-com-awns-visual]
    if { ($version == {}) || ([lindex $version 1] != 1.0) } {
    return 0
    }
    mcp21.server_notify dns-com-awns-visual-getusers 
    return 1
}

# --------------------------------------------------------------------------
# S->C API

# replace existing information with new information

proc visual.update_self id {
    global visual_db
    set visual_db(self) $id
    visual.dispatch update_self
}

proc visual.update_location locationid {
    global visual_db
    set visual_db(location) $locationid
    visual.dispatch update_location
}

# merge topology with existing topology, overwriting existing
# entries
proc visual.update_topology topology {
    global visual_db
    foreach record [concat $visual_db(topology) $topology] {
    set tmp([lindex $record 0]) [lrange $record 1 end]
    }
    set new_topology {}
    foreach roomid [array names tmp] {
    lappend new_topology [concat [list $roomid] $tmp($roomid)]
    }
    set visual_db(topology) $new_topology
    visual.dispatch update_topology
}

# replace any existing information with new info
proc visual.update_users users {
    global visual_db
    set visual_db(users) $users
    visual.dispatch update_users
}

proc ansi.remove_tags {string} {
set ansicodes "\\\[(random|normal|null|bold|unbold|bright|unbright|red|green|yellow|blue|purple|cyan|gray|grey|magenta|white|underline|inverse|blink|unblink|beep)\\\]"
set replace [regsub -all $ansicodes $string ""]
return $replace
}
