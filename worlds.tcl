
client.register worlds start
client.register worlds stop

proc worlds.start {} {
    global worlds_worlds
    set worlds_worlds {}

    worlds.create_default_file

    worlds.load

    set current [worlds.get_current]
    if { $current != "" } {
        worlds.unset $current IsCurrentWorld
    }

    set file [worlds.file]
    worlds.update_mtime $file
}

proc worlds.stop {} {
    if { [worlds.save_needed] == 1 } {
        worlds.save
    }
}

proc worlds.get_generic { hardcoded option optionClass directive {which ""}} {
    set value $hardcoded
    catch {
        set d ""
        set default [worlds.get_default $directive]
        if { $default != {} } { set d [lindex $default 0] }
        if { $d != "" } { set value $d }
    }
    if { $option != {} && $optionClass != {} } {
        set o [option get . $option $optionClass]
        if { $o != "" } { set value $o }
    }
    if { $which == "" } {
        catch { set value [worlds.get [worlds.get_current] $directive] }
    } {
        catch { set value [worlds.get $which $directive] }
    }
    return $value
}

set worlds_default_tkm "
World: DEFAULT WORLD
IsDefaultWorld: 1
ConnectScript: connect %u %p
colourbackground: #ffffc6
colourforeground: #000000

World: AcadianaMOO
Host: acadianamoo.org
Port: 6556
Description: Acadiana is a virtual space that reflects the geography, culture and humor of Southwestern Louisiana, and is primarily intended as a teaching space.
Website: http://acadianamoo.org/

World: AnsibleMOO
Host: ansiblemoo.org
Port: 6000
Description: AnsibleMOO is a roleplaying game based on the books Enter's Game and Ender's Shadow by Orson Scott Card.
Website: http://ansiblemoo.org/

World: ASI MOO
Host: moo.asi.org
Port: 7777
Description: The Artemis Society International meeting server.
Website: http://www.asi.org/adb/09/08/04/moo.html

World: BayMOO
Host: baymoo.org
Port: 8888
Shortlist: On
Description: BayMOO is a public MOO for the exploration of the San Francisco Bay Area in text based virtual reality.
Website: http://www.baymoo.org:4242/

World: BrightMOO
Host: brightmoo.genesismuds.com
Port: 7760
Website: http://brightmoo.genesismuds.com/
Description: BrightMOO is an experiment.  It is a proof of concept, designed to demonstrate the feasibility of building client-side, three-dimensional environments using existing MOO technology.

World: ComMOOnity
Host: cmoo.blissed.org
Port: 4242
Website: http://cmoo.blissed.org:4243/
Description: ComMOOnity was started on November 5th, 1996 as an experiment in human factors and human computer interaction at the Human-Computer Cooperative Problem Solving Lab at the University of Illinois, Urbana-Champaign campus.

World: Cyber Media Culture
Host: cmc.uib.no
Port: 8888
Website: http://cmc.ub.no:8000/

World: Dhalgren
Host: dhalgren.briar.com
Port: 7777
Website: http://www.mentallandscape.com/Dhalgren.htm
Shortlist: On

World: FooMOO
Host: foomoo.org
Port: 4500
Website: http://www.foomoo.org
Description: FooMOO is a MOO designed for the teaching and practicing of MOO programming. There is no theme, and few restrictions

World: Fractured
Host: fracturedproject.net
Port: 5139
Website: http://fracturedproject.net/

World: Ghostwheel
Host: moo.ghostmoo.org
Port: 6969
Website: http://fazigu.org/~quinn/ghost/

World: Ghostwheel Redux
Host: esque.com
Port: 6969
Website: http://ghostredux.wikispaces.com/

World: Harper's Tale
Host: moo.harpers-tale.com
Port: 7007
Website: http://www.harpers-tale.com/
Description: Harper's Tale is a text-based online roleplaying game, a simulation of the world of Pern, created by Anne McCaffrey in her \"Dragonriders of Pern\" novels.

World: HellMOO
Host: hellmoo.org
Port: 7777
Website: http://hellmoo.org
Description: HellMOO is a post-apocalyptic text based role-playing game. It is set after an atomic conflict has brought down the great civilizations of the 21st century.

World: HogwartsMOO
Host: hogwartsmoo.net
Port: 7500
Website: http://www.hogwartsmoo.net/
Description: HogwartsMOO is one of the first online Harry Potter themed roleplay games. It is considered alternate universe, as none of the main characters from the books will ever show up, nor will the storylines contained in those books ever appear on-game.

World: Holotrek
Host: holotrek.org
Port: 1701
Website: http://www.holotrek.org/
Description: HoloTrek is a Star Trek themed role-playing game on a timeline that branched from the events of TNG/DS9 around the first season of DS9.

World: LambdaMOO
Host: lambda.moo.mud.org
Port: 8888
Shortlist: On

World: Meadow
Host: hayseed.net
Port: 7777
Shortlist: On
Website: http://www.hayseed.net/meadow.html

World: MidgardMOO
Host: moo.midgard.org
Port: 1359

World: Miriani
Host: toastsoft.net
Port: 1234
Website: http://www.toastsoft.net
Description: Miriani is a multi-player online roleplaying game in which you take on the role of a starship pilot. Your goal is simply to make a life for yourself through whatever means possible.

World: MOO Canada, Eh?
Host: moo.ca
Port: 7777

World: MOOMellow
Host: moo.chilipepper.com
Port: 7777
Website: http://www.chilipepper.com:7000/

World: MOOsaico
Host: moo.di.umhino.pt
Port: 7777
Website: http://moosaico.com/
Description: MOOsaico is the oldest text based virtual environment operating in Portugal and for some time the only one in the world with multilingual support.

World: Once Upon A MOO
Host: rupert.twyst.org
Port: 7777
Description: Once Upon A Moo is faerie tale, children's story and nursery rhyme based.

World: OpalMOO
Host: moo.opal.org
Port: 7878
Description: The Theme of OpalMOO is not easy to put into one or two phrases, but if it were, it would probably be, \"Gritty and Sensual.\" Things like abandoned warehouses and movie theatres are great. Things like Space Ports and shiny new office buildings are not.
World: Phantasy World
Host: pworld.dyndns.org
Port: 1111
Website: http://pworld.dyndns.org/

World: Rupert
Host: rupert.twyst.org
Port: 9040
Website: http://rupert.twyst.org/
Description: A MOO based on the universe as described by Douglas Adams

World: Ryksyll
Host: moo.ryksyll.org
Port: 8888
Website: http://moo.ryksyll.com:8889/
Description: Ryksyll MOO is a world based on the works of Peter Wright on the land of Mycle.

World: Sindome
Host:moo.sindome.org
Port: 5555 
Website: http://sindome.org/
Description: Sindome is an online text based Cyberpunk Role Playing game.

World: Star Conquest
Host: squidsoft.net
Port: 7777
Website: http://www.squidsoft.net
Description: The original pulp science fiction multiplayer roleplaying adventure

World: Star Trek: Phoenix Rising
Host: kydance.net
Port: 2009
Website: http://phxrising.org/

World: TecfaMOO
Host: tecfamoo.unige.ch
Port: 7777
Website: http://tecfa.unige.ch/moo/tecfamoo.html
Description: The TecfaMOO is a Virtual Space for Educational Technology, Education, Research and Life at TECFA, School of Psychology and Education, University of Geneva, Switzerland.
ShortList: On

World: The Ethereal Kingdom
Host: keep.quarteredcircle.net
Port: 2035
Website: http://www.virtadpt.net/

World: the-night.com
Host: the-night.com
Port: 2000
Website: http://www.the-night.com/
Description: 'the-night.com' (TNC) is a text-based game set in a fictional island chain in the Atlantic.

World: University
Host: moo-education-online.com
Port: 7777
Website: http://moo-education-online.com/
Description: Welcome to the wonderful world of University. Find within our online text game monsters, maidens and mayhem.

World: VRoma
Host: vroma.org
Port: 8200
Website: http://www.vroma.org/

World: Waterpoint
Host: waterpoint.moo.mud.org
Port: 8301
Website: http://waterpoint.moo.mud.org/

World: Wayfar 1444
Host: wayfar1444.com
Port: 7777
Website: http://www.wayfar1444.com/
Description: multiplayer text adventure in the far future, on an alien planet

World: Weyrmount II
Host: moo.weyrmount.org
Port: 8000

World: Where No One Has Gone Before
Host: game.wnohgb.org
Port: 1701
Website: http://www.wnohgb.org

World: X-Men: Another Day Dawns
Host: kydance.net
Port: 3113
Website: http://x-menanotherdaydawns.wikidot.com/

World: YibMOO
Host: yibmoo.dyndns.org
Port: 7777
"

proc worlds.default_tkm {} {
    global worlds_default_tkm
    return [split $worlds_default_tkm "\n"]
}

proc worlds.preferred_file {} {
    global tcl_platform env tkmooLibrary
    set dirs {}
    switch $tcl_platform(platform) {
    windows {
        set file worlds.tkm
            if { [info exists env(TKMOO_LIB_DIR)] } {
                lappend dirs [file join $env(TKMOO_LIB_DIR)]
            }
            if { [info exists env(HOME)] } {
                lappend dirs [file join $env(HOME) tkmoo]
            }
            lappend dirs [file join $tkmooLibrary]
    }
    unix -
    default {
        set file .worlds.tkm
            if { [info exists env(TKMOO_LIB_DIR)] } {
                lappend dirs [file join $env(TKMOO_LIB_DIR)]
            }
            if { [info exists env(HOME)] } {
                lappend dirs [file join $env(HOME) .tkMOO-lite]
            }
            lappend dirs [file join $tkmooLibrary]
        }
    }

    foreach dir $dirs {
        if { [file exists $dir] &&
             [file isdirectory $dir] &&
             [file writable $dir] } {
            return [file join $dir $file]
        }
    }

    return [file join [pwd] $file]
}

proc worlds.file {} {
    global tkmooLibrary env

    set files {}

    lappend files [file join [pwd] worlds.tkm]
    lappend files [file join [pwd] .worlds.tkm]
    lappend files [worlds.preferred_file]

    foreach file $files {
        if { [file exists $file] } {
        return $file
        }
    }

    return ""
}

set worlds_last_read 0

proc worlds.update_mtime file {
    global worlds_last_read
    if { [catch { set mtime [file mtime $file] }] != 0 } {
    return
    }
    set worlds_last_read $mtime
}

proc worlds.file_changed file {
    global worlds_last_read
    if { [catch { set mtime [file mtime $file] }] != 0 } {
    window.displayCR "Can't stat file (.file_changed) $file" window_highlight
    return
    }
    if { $mtime != $worlds_last_read } {
        return 1
    } {
        return 0
    }
}

proc worlds.read_worlds file {
    set tmp {}
    set worlds_file ""
    catch { set worlds_file [open $file "r"] }
    if { $worlds_file == "" } {
    window.displayCR "Can't read file $file" window_highlight
    return $tmp
    }
    while { [gets $worlds_file line] != -1 } {
    lappend tmp $line
    }
    close $worlds_file
    return $tmp
}

proc worlds.new_world {} {
    return [util.unique_id world]
}

proc worlds.load {} {
    global worlds_worlds worlds_worlds_db tkmooLibrary

    set file [worlds.file]

    if { $file != "" } {
        if { [worlds.file_changed $file] == 0 } {
        return 0
    }
    set worlds_lines [worlds.read_worlds $file]
    worlds.update_mtime $file
    } {
    set worlds_lines [worlds.default_tkm]
    }

    catch { unset worlds_worlds_db }
    set worlds_worlds {}
    set index [worlds.new_world]

    set new_worlds [worlds.apply_lines $worlds_lines]
    if { $new_worlds != {} } {
    set worlds_worlds [concat $worlds_worlds $new_worlds]
    }

    worlds.make_default_world

    window.post_connect

    worlds.untouch

    return 1
}

proc worlds.apply_lines lines {
    global worlds_worlds_db
    set new_worlds {}
    foreach line $lines {
        if { [regexp {^ *#} $line] == 1 } {
        continue
        }
    if { [regexp {^([^:]+): (.*)} $line _ key value] == 1 } {
            set lkey [string tolower $key]
        if { $lkey == "world" } {
            set world $value
                set index [worlds.new_world]
        lappend new_worlds $index
        worlds.set $index Name $world
            } {
            if { [info exists worlds_worlds_db($index:$lkey)] } {
                worlds.set $index $key "[worlds.get $index $key]\n$value"
        } {
            worlds.set $index $key $value
        }
        }
    }
    }
    return $new_worlds
}

proc worlds.create_default_file {} {
    set file [worlds.file]
    if { $file != "" } { return }

    set file [worlds.preferred_file]

    set fd ""
    catch { set fd [open $file "w+"] }
    if { $fd == "" } {
        window.displayCR "Can't write to file $file" window_highlight
        return
    }

    puts $fd "# $file"
    puts $fd "# This file is created automatically by the preferences editor"
    puts $fd "# any changes you make by hand to this file will be lost."

    foreach line [worlds.default_tkm] { puts $fd $line }
    close $fd
    if { [ platform.is_linux ] || [ platform.is_osx ]} {
        file attributes $file -permissions "rw-------"
    }
}

proc worlds.save {} {
    global worlds_worlds_db

    set file [worlds.file]
    if { $file == "" } {
        set file [worlds.preferred_file]
    }

    set worlds [worlds.worlds]

    set directives {}
    foreach key [array names worlds_worlds_db] {
        set wd [split $key ":"]
        set d [lindex $wd 1]
        if { $d == "name" } { continue }
        set all_used_directives($d) 1
    }
    catch { set directives [array names all_used_directives] }



    foreach d $directives {
        set get_directive [preferences.get_directive $d]
        set default_if_empty($d)      [util.assoc $get_directive default_if_empty]
        set directive_type($d)        [lindex [util.assoc $get_directive type] 1]
        set directive_has_default($d) [worlds.get_default $d]
    }

    set the_default_world [worlds.default_world]

    set fd ""
    catch { set fd [open $file "w+"] }
    if { $fd == "" } {
        window.displayCR "Can't write to file $file" window_highlight
        return
    }


    puts $fd "# $file"
    puts $fd "# This file is created automatically by the preferences editor"
    puts $fd "# any changes you make by hand to this file will be lost."


    foreach world $worlds {

        if { [info exists worlds_worlds_db($world:mustnotsave)] } {
            continue
        }

        puts $fd "# ----"
        puts $fd "World: $worlds_worlds_db($world:name)"

        foreach directive $directives {
            if { [info exists worlds_worlds_db($world:$directive)] } {

                if { ($worlds_worlds_db($world:$directive) == {}) &&
                     ($default_if_empty($directive) != {}) } {
                     continue
                }

                set has_default $directive_has_default($directive)
                if { ($world != $the_default_world) && ($has_default != {}) } {

                    set db     $worlds_worlds_db($world:$directive)
                    set default [lindex $has_default 0]

                    set type $directive_type($directive)

                    if { $type == "boolean" } {
                        set db      [string tolower $db]
                        set default [string tolower $default]
                    }

                    if { $db == $default } { continue }
                }

                set lines [split $worlds_worlds_db($world:$directive) "\n"]

                if { [llength $lines] > 1 } {

                    set last [lindex [lrange $lines end end] 0]

                    if { $last == {} } {
                      .set lines [lrange $lines 0 [expr [llength $lines] - 2]]
                    }

                    foreach line $lines { puts $fd "$directive: $line" }
                } {
                    puts $fd "$directive: $worlds_worlds_db($world:$directive)"
                }
            }
        }
    }
    close $fd
    window.post_connect
}

proc worlds.sync {} {
    worlds.save
    worlds.load
}

proc worlds.worlds { } {
    global worlds_worlds
    return $worlds_worlds
}

proc worlds.touch {} {
    global worlds_save_needed
    set worlds_save_needed 1
}

proc worlds.untouch {} {
    global worlds_save_needed
    set worlds_save_needed 0
}

proc worlds.save_needed {} {
    global worlds_save_needed
    return $worlds_save_needed
}

proc worlds.get { world key } {
    global worlds_worlds_db
    return $worlds_worlds_db($world:[string tolower $key])
}

proc worlds.get_default directive {
    set default [util.assoc [preferences.get_directive $directive] default]
    if { $default != {} } {
        set default [list [lindex $default 1]]
    }
    catch { set default [list [worlds.get [worlds.default_world] $directive]] }
    return $default
}

proc worlds.set_if_different { world key { value NULL }} {
    if { [catch {set v [worlds.get $world $key]}] ||
        $v != $value } {
        worlds.set $world $key $value
    }
}

proc worlds.set { world key { value NULL }} {
    global worlds_worlds_db
    if { ($value == {}) &&
         ([util.assoc [preferences.get_directive $key] default_if_empty] != {}) } {
        catch { unset worlds_worlds_db($world:[string tolower $key]) }
    } {
        set worlds_worlds_db($world:[string tolower $key]) $value
    }
    if { [string tolower $key] != "iscurrentworld" } { worlds.touch }
}

proc worlds.unset { world key } {
    global worlds_worlds_db
    catch { unset worlds_worlds_db($world:[string tolower $key]) }
    if { [string tolower $key] != "iscurrentworld" } { worlds.touch }
}

proc worlds.copy {world copy} {
    global worlds_worlds_db

    foreach key [array names worlds_worlds_db "$world:*"] {
        regsub "^$world:" $key {} param
        if { $param == "mustnotsave" } {
            continue
        }
        set worlds_worlds_db($copy:$param) $worlds_worlds_db($key)
    }

    worlds.touch

    return $copy
}

proc worlds.delete world {
    global worlds_worlds_db worlds_worlds
    set index [lsearch -exact $worlds_worlds $world]
    if { $index != -1 } {
        set worlds_worlds [lreplace $worlds_worlds $index $index]
        foreach key [array names worlds_worlds_db "$world:*"] {
            unset worlds_worlds_db($key)
        }
        worlds.touch
    }
}

proc worlds.create_new_world {} {
    global worlds_worlds
    set world [worlds.new_world]
    lappend worlds_worlds $world
    worlds.touch
    return $world
}

proc worlds.get_current {} {
    global worlds_worlds
    foreach world $worlds_worlds {
        set is_current 0
        catch { set is_current [worlds.get $world IsCurrentWorld] }
        if { $is_current } { return $world }
    }
    return ""
}

proc worlds.set_current world {
    set current [worlds.get_current]
    if { $current != "" } {
        worlds.unset $current IsCurrentWorld
    }
    if { $world != "" } {
        worlds.set $world IsCurrentWorld 1
    }
}

#

proc worlds.set_special {world directive {value 1}} {
    while { [set special [worlds.get_special $directive $value]] != "" } {
        worlds.unset $special $directive
    }
    worlds.set $world $directive $value
}

proc worlds.get_special {directive {value 1}} {
    global worlds_worlds
    foreach world $worlds_worlds {
        set is_special 0
        if { $value == 0 } { set is_special 1 }
        catch { set is_special [worlds.get $world $directive] }
        if { $is_special == $value } { return $world }
    }
    return ""
}

proc worlds.match_world expr {
    global worlds_worlds
    set tmp {}
    foreach world $worlds_worlds {
        if { [string match $expr [worlds.get $world Name]] == 1 } {
            lappend tmp $world
        }
    }
    return $tmp
}

proc worlds.default_world {} {
    global worlds_worlds
    foreach world $worlds_worlds {
      set default -1
      catch { set default [worlds.get $world IsDefaultWorld] }
      if { $default == 1 } { return $world }
    }
    return -1
}

proc worlds.make_default_world {} {
    if { [worlds.default_world] == -1 } {
        set world [worlds.create_new_world]
        worlds.set $world IsDefaultWorld 1
        worlds.set $world Name "DEFAULT WORLD"
        worlds.set $world ConnectScript "connect %u %p"
    }
}
