

client.register awns start 60

proc awns.start {} {
    awns.create_worlds_entry
    window.menu_help_add "Visit Moo.Awns.Com" awns.do_connect
}

proc awns.create_worlds_entry {} {
    set host "moo.awns.com"

    if { [set world [awns.worlds_entry]] == -1 } {
        set world [worlds.create_new_world]
        worlds.set $world ShortList On
        worlds.set $world IsGuestAtMooDotAwnsDotCom 1
    }


    worlds.set_if_different $world Name "Guest@Moo.Awns.Com"
    worlds.set_if_different $world Host $host
    worlds.set_if_different $world Port 8888
    worlds.set_if_different $world Login guest
    worlds.set_if_different $world ConnectScript "connect %u %p"

    open.fill_listbox
    window.post_connect
}

proc awns.worlds_entry {} {
    global worlds_worlds
    foreach world $worlds_worlds {
        set is -1
        catch { set is [worlds.get $world IsGuestAtMooDotAwnsDotCom] }
        if { $is == 1 } {
            return $world
        }
    }
    return -1
}

proc awns.do_connect {} {
    awns.create_worlds_entry
    set world [awns.worlds_entry]
    client.connect_world $world
}
#
#
