client.register userlist start 60
client.register userlist incoming 39
client.register userlist client_disconnected

proc userlist.start {} {
global tag
set tag ""
window.menu_tools_add "Userlist on/off" userlist.userlist_toggle
mcp21.register dns-com-vmoo-userlist 1.0 \
        dns-com-vmoo-userlist userlist.do_dns_com_vmoo_userlist
userlist.iconinfo
userlist.build
    }

proc userlist.incoming event {
    global mcp21_use mcp21_authentication_key tag

    if { $mcp21_use == 0 } {
        return [modules.module_deferred]
    }
    
    set line [db.get $event line]
    set PREFIX {#$}
    set MATCH "$PREFIX*"
    if { [string match $MATCH $line] == 0 } {
        # nothing to do with us
        return [modules.module_deferred]
    }
    if {[regexp "#\\$#dns-com-vmoo-userlist\\s$mcp21_authentication_key\\sicons\\*:\\s(.*)\\sfields\\*:\\s(.*)\\sd\\*:\\s(.*)\\s_data-tag:\\s(.*)" $line all icons field d dt]} {
        set tag $dt
        return [modules.module_ok]
    } 
    if {[regexp "#\\$#\\*\\s$tag\\s(.*):\\s(.*)" $line lot fields args]} {
        catch {userlist.$fields $args}
        return [modules.module_ok]
    }
}

proc userlist.icons icons {
    set icons [string range $icons 1 end-1]
    catch {userlist.iconset $icons}
}

proc userlist.d data {
    set char [string range $data 0 0]
    set data [string range $data 2 end-1]
    if {$char == "-"} {
        userlist.delete $data
    } elseif {$char == "="} {
        userlist.create
        userlist.users $data
    } elseif {$char == "+"} {
        set data [string map {", " " "} $data]
        userlist.add [lindex $data 1] [lindex $data 0] [lindex $data 2]
    } elseif {$char == "<"} {
        set data [string map {", " " "} $data]
        foreach x $data {
            userlist.idleset $x
        }
    } elseif {$char == ">"} {
        userlist.idleunset $data
    } elseif {$char == "\["} {
        set data [string map {", " " "} $data]
        foreach x $data {
            userlist.awayset $data
        }
    } elseif {$char == "\]"} {
        userlist.awayunset $data
    } elseif {$char == "("} {
        userlist.cloak $data
    } elseif {$char == ")"} { 
        userlist.decloak $data
    } elseif {$char == "*"} {
        set data [string map {", " " "} $data]
        userlist.userupdate [lindex $data 1] [lindex $data 0] [lindex $data 2]
    }
}

proc userlist.build {} {
if { [winfo exists .listbox] } { return }
    frame .listbox -background white
    listbox .listbox.listbox2 -exportselection 1 -bg white -relief flat -height 200
    pack .listbox -fill both
    pack .listbox.listbox2 -fill both
    bind .listbox.listbox2 <ButtonRelease-1> {showindices}
    
    set m [menu .popupMenu]
    .popupMenu add command -label "" -command bell

    bind .listbox.listbox2 <ButtonRelease-3> {tk_popup .popupMenu %X %Y}
}
    
proc userlist.create {} {
    if {[winfo exists .listbox] == 0} {
        userlist.build
    }
    window.add_sidebar .listbox
    window.repack
}

proc showindices {} {
    .popupMenu delete 1 end
    .popupMenu add command -label "info [user_info]" -command {io.outgoing "@info [user_num]"}
    .popupMenu add command -label "look at [user_info]" -command {io.outgoing "look [user_num]"}
    .popupMenu add command -label "wave at [user_info]" -command {io.outgoing "wave [user_num]"}
    .popupMenu add command -label "find [user_info]" -command {io.outgoing "@find [user_num]"}
    .popupMenu add command -label "knock [user_info]" -command {io.outgoing "@knock [user_num]"}
    .popupMenu add command -label "invite [user_info]" -command {io.outgoing "@invite [user_num]"}
    .popupMenu add command -label "join [user_info]" -command {io.outgoing "@join [user_num]"}
    .popupMenu add command -label "beep [user_info]" -command {io.outgoing "@beep [user_num]"}
}
       
proc user_info {} {
    set user [.listbox.listbox2 curselection]
    if { $user=={} } {
        return "N/A"
    } else {
        return [.listbox.listbox2 get $user]
    }
}
    
proc user_num {} {
    set user [.listbox.listbox2 curselection]
    if { $user=={} } { ;#If there is no job
        return "N/A"
    } else {
        return [db.get usrnum [lindex [.listbox.listbox2 get 0 end] $user]]
    }
}

proc userlist.add {name number icon} {
    if {[catch {db.get users $number}] == 0} {return}
    db.set users $number $name
    db.set usrnum $name $number
    db.set icon $number $icon
    if {[winfo exists .listbox]} {
        .listbox.listbox2 insert end $name
            userlist.iconchange $number $icon
    }
}
   
proc userlist.delete number {
    set users [.listbox.listbox2 get 0 end]
    set user [db.get users $number]
    set pos [lsearch -exact $users $user]
    if {[winfo exists .listbox]} {
        .listbox.listbox2 delete $pos
    }
    catch {db.unset users $number ""}
    catch {db.unset icon $number ""}
}

proc userlist.fields {string} {
    global usr_num
    split $string ,
    set usr_num [llength $string]
}

proc userlist.users {list} {
if {[winfo exists .listbox] == 1} {
.listbox.listbox2 delete 0 end
}
set list2 [string map {"," ""} $list] 
    foreach x $list2 {
        userlist.add [lindex $x 1] [lindex $x 0] [lindex $x 2]
    }
}

proc userlist.userlist_toggle {} {
    global window_sidebars
    if { [lsearch -exact $window_sidebars .listbox] != -1  } { userlist.destroy } { userlist.create }
}

proc userlist.destroy {} {
    window.remove_sidebar .listbox
    window.repack
}

proc userlist.iconset list {
    set list [string map {", " " "} $list]
    set num 1
    foreach x $list {
        db.set icons $num $x
        incr num
    }
}

proc userlist.iconcolour num {
    set icon [db.get icons $num]
    return [db.get icbg $icon]
}

proc userlist.textcolour num  {
    set icon [db.get icons $num]
    set colour [db.get icfg $icon]
    return $colour
}

proc userlist.iconchange {num icon} {
    set users [.listbox.listbox2 get 0 end]
    set user [db.get users $num]
    set pos [lsearch -exact $users $user]
    set text [userlist.textcolour $icon]
    set bg [userlist.iconcolour $icon]
    .listbox.listbox2 itemconfigure $pos -background $bg -foreground $text
}

proc userlist.client_disconnected {} {
    global tag
    set tag ""
    if {[winfo exists .listbox] == 1} {
        .listbox.listbox2 delete 0 end
    }
    db.drop users
    db.drop usrnum
    db.drop icon 
    return [modules.module_deferred]
}

proc userlist.iconinfo {} {
    set icons {Idle Away "Idle+Away" Friend Newbie Inhabitant "Inhabitant+" Schooled Wizard Key Star}
    set fg {black black white black black black yellow lightblue yellow yellow black}
    set bg {white grey black yellow green lightblue blue purple red brown pink}
    foreach x $icons y $fg z $bg {
        db.set icbg $x $z
        db.set icfg $x $y
    }
}

proc userlist.idleset num {
    if {[catch {db.get away $num}]} {
        db.set idle $num 1
        set icon "Idle"
    } {
        db.set idle $num 1
        set icon "Idle+Away"
    }
    set bg [db.get icbg $icon]
    set fg [db.get icfg $icon]
    set users [.listbox.listbox2 get 0 end]
    catch {set user [db.get users $num]}
    set pos [lsearch -exact $users $user]
    .listbox.listbox2 itemconfigure $pos -background $bg -foreground $fg
}

proc userlist.idleunset num {
    if {[catch {db.get away $num}]} {
        db.unset idle $num ""
        set icon [db.get icons [db.get icon $num]]
    } {
        db.unset away $num ""
        set icon "Away"
    }
    set bg [db.get icbg $icon]
    set fg [db.get icfg $icon]
    set users [.listbox.listbox2 get 0 end]
    catch {set user [db.get users $num]}
    set pos [lsearch -exact $users $user]
    .listbox.listbox2 itemconfigure $pos -background $bg -foreground $fg
}

proc userlist.awayset num {
    if {[catch {db.get idle $num}]} {
        db.set away $num 1
        set icon "Away"
    } {
        db.set away $num 1
        set icon "Idle+Away"
    }
    set bg [db.get icbg $icon]
    set fg [db.get icfg $icon]
    set users [.listbox.listbox2 get 0 end]
    catch {set user [db.get users $num]}
    set pos [lsearch -exact $users $user]
    .listbox.listbox2 itemconfigure $pos -background $bg -foreground $fg
}

proc userlist.awayunset num {
    if {[catch {db.get idle $num}]} {
        db.unset away $num ""
        set icon [db.get icons [db.get icon $num]]
    } {
        db.unset away $num ""
        set icon "Idle"
    }
    set bg [db.get icbg $icon]
    set fg [db.get icfg $icon]
    set users [.listbox.listbox2 get 0 end]
    catch {set user [db.get users $num]}
    set pos [lsearch -exact $users $user]
    .listbox.listbox2 itemconfigure $pos -background $bg -foreground $fg
}

proc userlist.cloak num {
    set users [.listbox.listbox2 get 0 end]
    set user [db.get users $num]
    set pos [lsearch -exact $users $user]
    if {[winfo exists .listbox]} {
        .listbox.listbox2 delete $pos
    }
}

proc userlist.decloak num {
    set user [db.get users $num]
    if {[winfo exists .listbox]} {
        .listbox.listbox2 insert end $user
        userlist.iconchange $num [db.get icon $num]
    }
}

proc userlist.userupdate {name number icon} {
    db.set users $number $name
    db.set usrnum $name $number
    db.set icon $number $icon
    userlist.iconchange $number $icon
}
