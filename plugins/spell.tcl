#
#       tkMOO
#       ~/.tkMOO-light/plugins/spell.tcl
#

# tkMOO-light is Copyright (c) Andrew Wilson 1994,1995,1996,1997,1998,
#                                            1999,2000,2001
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

# This plugin provides a simple spell checking interface.  The
# procedure 'spell.check $words' returns a list of unrecognised words.
# For example:
#
#    [spell.check "cat dog hipomotimouse"] => hipomotimouse
#
# On UNIX systems words are checked against the standard dictionary
# in /usr/dict/words by using the UNIX 'look' command.  On windows
# systems you can use any plain-text file of words as
# a dictionary (Main Dictionary in the Preferences Editor, no need
# to define a value for this if you're using UNIX).  Unrecognised
# words are displayed on the command line in red.  Right-clicking on
# an unrecognised word will add it to a personal dictionary (Personal
# Dictionary in the Preferences Editor).

# TODO
# o     <keyRelease> and <Return> might mean it's spellchecking
#    the line when you press <Return>, that's unnecessary.
# o     Output window can be used as dictionary too, permits people
#    to type 'bwahahah' if someone else has already said it.  Common
#    for chat use.

client.register spell start
client.register spell client_connected
client.register spell client_disconnected

proc spell.start {} {
    .input tag configure spell_TYPO -foreground red
    bind .input <KeyRelease> +spell.handle_keyrelease

    # unix users would normally leave this entry blank
    preferences.register spell {Special Forces} {
        { {directive SpellDictionary}
            {type file}
            {filetypes {
                {{Text Files} {.txt} TEXT}
                {{All Files} {*} TEXT}
                } }
            {default ""}
            {display "Main Dictionary"} }
    }

    preferences.register spell {Special Forces} {
        { {directive SpellPersonal}
            {type file}
            {filetypes {
                {{Text Files} {.txt} TEXT}
                {{All Files} {*} TEXT}
                } }
            {default ""}
            {display "Personal Dictionary"} }
    }

    edittriggers.register_alias spell.check spell.check
    spell.set_available 0
    spell.zero_task
}

proc spell.zero_task {} {
    global spell_task
    set spell_task 0
}

proc spell.client_connected {} {
    global spell_changed tcl_platform
    set spell_changed 0
    set dictionary [worlds.get_generic "" {} {} SpellDictionary]
    set personal_dictionary [worlds.get_generic "" {} {} SpellPersonal]

    spell.set_available 0
    if { $tcl_platform(platform) != "unix" } {
    if { [file exists $dictionary] ||
         [file exists $personal_dictionary] } {
            spell.set_available 1
        }
    } {
        spell.set_available 1
    }

    spell.load_dictionary spell_db $dictionary
    if { [file exists $personal_dictionary] } {
    # personal dictionary may be defined in preferences, but
    # might not exist because no words have been saved.
        spell.load_dictionary spell_db_personal $personal_dictionary
    }

    return [modules.module_deferred]
}

proc spell.client_disconnected {} {
    spell.stop_loading
    global spell_changed
    if { $spell_changed } {
        spell.save_dictionary spell_db_personal [worlds.get_generic "" {} {} SpellPersonal]
    }
    return [modules.module_deferred]
}

proc spell.available {} {
    global spell_available
    return $spell_available
}

proc spell.set_available available {
    global spell_available
    set spell_available $available
}

proc spell.load_dictionary { db file } {
    global spell_task_db
    set fh [spell.open_dictionary $file]
    if { $fh == 0 } { return }
    global $db
    catch { unset $db }
    set spell_task_db($fh,task) [after 200 spell.read_dictionary $db $fh]
}

proc spell.stop_loading {} {
    global spell_task_db
    foreach key [array names spell_task_db "*,task"] {
    catch { after cancel $spell_task_db($key) }
        catch { unset spell_task_db($key) }
    }
}

proc spell.read_dictionary {db fh} {
    global spell_task_db
    global $db
    set MAX_LINES 10
    set count 0
    while { $count < $MAX_LINES &&
       [gets $fh line] != -1 } {
        set data [list]
        foreach word $line {
            lappend data $word 1
        }
        array set $db $data
    incr count
    }
    # update for any text in the .input widget
    spell.do_marks
    if { [eof $fh] } {
        close $fh
        catch { unset spell_task_db($fh,task) }
    } {
        set spell_task_db($fh,task) [after 200 spell.read_dictionary $db $fh]
    }
}

proc spell.open_dictionary file {
    if { $file == "" } {
    return 0
    }
    set fh ""
    catch { set fh [open $file "r"] }
    if { $fh == "" } {
        window.displayCR "Can't open dictionary $file" window_highlight
        return 0
    }
    return $fh
}

proc spell.save_dictionary { db file } {
    global $db
    if { $file == "" } {
    return
    }
    set fh ""
    catch { set fh [open $file "w"] }
    if { $fh == "" } {
        window.displayCR "Can't open dictionary $file" window_highlight
        return
    }

    # write out 40 words per line
    set WORDS_PER_LINE 40
    set CR ""
    set SPACE ""
    set count 0
    foreach word [lsort [array names $db]] {
    if { $count == 0 } {
        puts -nonewline $fh $CR
        set CR "\n"
    }
    puts -nonewline $fh "$SPACE$word"
    set SPACE " "
    incr count
    if { $count > $WORDS_PER_LINE } {
        set count 0
        set SPACE ""
    }
    }
    close $fh
}

proc spell.handle_keyrelease {} {
    global spell_task
    if { $spell_task != 0 } {
        after cancel $spell_task
    }
    # 1/4 second after the last keypress, run the spell-checker
    set spell_task [after 250 {spell.do_marks;spell.zero_task}]
}

proc spell.do_marks {} {
    if { [spell.available] == 0 } { return }
    set text [.input get 1.0 end]
    # split words on punctuation, UNIX 'look' isn't smart enough
    # to do this for us
    regsub -all {[^A-Za-z]} $text { } text
    set wrong [spell.check $text]
    spell.unmark_words .input
    if { $wrong != {} } {
        spell.mark_words .input $wrong
    }
}

proc spell.can.look {} {
    global spell_can
    if { [info exists spell_can(look)] } {
    return $spell_can(look)
    }
    set LOOK "look"
    set look ""
    catch {
    set look [open "| $LOOK"]
    close $look
    }
    if { $look == "" } {
    set spell_can(look) 0
    } {
    set spell_can(look) 1
    }
    return $spell_can(look)
}

proc spell.can.ispell {} {
    global spell_can
    if { [info exists spell_can(ispell)] } {
    return $spell_can(ispell)
    }
    set ISPELL "ispell -a"
    set ispell ""
    catch {
    set ispell [open "| $ISPELL"]
    close $ispell
    }
    if { $ispell == "" } {
    set spell_can(ispell) 0
    } {
    set spell_can(ispell) 1
    }
    return $spell_can(ispell)
}

# UNIX look outputs one or more lines of words which contain the
# substring given in $word.  'look' uses a plain-text dictionary
# common to most UNIX systems, often referred to as /usr/dict/words,
# or /usr/share/dict/web2 etc.  Return the words in a list
proc spell.look word {
    # full path to 'look' command, or make sure it's in your $PATH
    set LOOK "look"
    set words [list]
    set look [open "| $LOOK $word"]
    while { [gets $look line] > 0 } {
        lappend words [string tolower $line]
    }
    catch {close $look}
    return $words
}

proc spell.ispell word {
    set ISPELL "ispell -a"
    set words [list]
    set ispell [open "| $ISPELL" "r+"]
    puts $ispell $word
    flush $ispell

    # skip the first line
    gets $ispell

    while { [gets $ispell line] > 0 } {
        if { [regexp {^[\*\+]} $line] } {
        set first [lindex $word 0]
            lappend words [string tolower $first]
        set word [lrange $word 1 end]
        }
    }
    catch {close $ispell}
    return $words
}

proc spell.check.unix text {
    global spell_db spell_db_personal
    set wrong [list]
    foreach word $text {
        if { [info exists spell_db($word)] } {
            if { $spell_db($word) == 0 } {
                # already known to be wrong
                lappend wrong $word
            }
            continue
        }
    if { [info exists spell_db_personal([string tolower $word])] } {
        continue
    }
    set found ""
    foreach command { ispell look } {
        if { [spell.can.$command] } {
                set found [spell.$command $word]
        break
        }
    }
        if { [lsearch -exact $found [string tolower $word]] != -1 } {
            # correct
            set spell_db($word) 1
            continue
        }
        # wrong
        set spell_db($word) 0
        lappend wrong $word
    }
    return $wrong
}

proc spell.check.windows text {
    global spell_db spell_db_personal
    set wrong [list]
    foreach word $text {
    if { [info exists spell_db([string tolower $word])] } {
        continue
    }
    if { [info exists spell_db_personal([string tolower $word])] } {
        continue
    }
        lappend wrong $word
    }
    return $wrong
}

proc spell.check text {
    global tcl_platform
    return [spell.check.$tcl_platform(platform) $text]
}

proc spell.add_personal word {
    global spell_db_personal spell_changed spell_db
    set spell_db_personal([string tolower $word]) 1
    # set it in the main dictionary too, this helps the rather
    # twisted logic in spell.check.unix
    set spell_db([string tolower $word]) 1
    set spell_changed 1
}

proc spell.mark_words {w words} {
    set text [$w get 1.0 end]
    foreach word $words {
    set from 1.0
    while { [set psn [$w search -nocase -forwards $word $from end]] != "" } {
            set len [string length $word]
        # work out where we expect this word to end, also where
        # we start our next search from
        set from [$w index "$psn + $len chars"]
        # work out the beginning and end of the word we're in...
        set beginning [$w index "$psn wordstart"]
        set ending [$w index "$psn wordend"]
        # only tag if we're tagging a whole word
        if { ($beginning == $psn) && ($ending == $from) } {
        set new_tag [util.unique_id spell_add]
        $w tag configure $new_tag
        $w tag bind $new_tag <Button3-ButtonRelease> "
            spell.add_personal $word
            spell.do_marks
        "
            $w tag add spell_TYPO $psn $from
            $w tag add $new_tag $psn $from
        }
    }
    }
}

proc spell.unmark_words w {
    set tags [$w tag names]
    $w tag remove spell_TYPO 1.0 end
    foreach tag $tags {
    if { [string match spell_add* $tag] } {
            $w tag delete $tag 1.0 end
    }
    }
}
