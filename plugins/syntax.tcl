############################################################
# syntax.tcl -- a syntax highlighting plugin for tkMOO-ttk
# written by R Pickett (emerson (at) hayseed.net)
#
# syntax.tcl versions up through 0.1.3 work with tkMOO-light.
# version 0.2.0 and later require tkMOO-ttk.
#
#
# tkMOO-ttk is a fork of tkMOO-SE and tkMOO-light aiming to take
# advantage of features of recent tk releases such as ttk.  It's
# intended to fit into the desktop environment of 2012 without
# looking or acting like 1995.
#
# tkMOO-light is an advanced chat/MOO client, written by Andrew Wilson.
# It can be found at <http://www.awns.com/tkMOO-light>.
#

client.register syntax start

proc syntax.start {} {
    edit.add_edit_function "Syntax off" { syntax.select "" }
    edit.register load syntax.do_load 70
}

proc syntax.do_load {w args} {
    global syntax_db

    if { [info exists syntax_db($w)] } {
        if { $args != {} } {
            set from_to [lindex [util.assoc [lindex $args 0] range] 1]
        } else {
            set from_to {}
        }
        syntax.select $syntax_db($w) $w $from_to
        $w.t highlight 1.0 end
    }
}

proc syntax.select {type w args} {
    global syntax_db

    set from_to [lindex $args 0]
    if { $type == "" } {
    catch [unset syntax_db($w)]
        set tags [$w.t tag names]
        foreach tag $tags {
            if { [string match syntax_* $tag] } {
                $w.t tag delete $tag
            }
        }
        catch { after cancel $syntax_task }
    } else {
        set syntax_db($w) $type
        syntax.activate $w $from_to
    }
}

proc syntax.activate {w from_to} {
    global syntax_db

    set type $syntax_db($w)

    syntax_${type}.initialize $w
}

############################################################
# syntax_moo_code.tcl
############################################################

client.register syntax_moo_code start

proc syntax_moo_code.start {} {
    edit.add_edit_function "MOO Syntax" {syntax.select "moo_code"}
    edit.register load syntax_moo_code.check
}

proc syntax_moo_code.initialize w {

    # TODO - make this into a 'theme' and put it out in color.tcl
    set solarized_base03  "#002b36"
    set solarized_base02  "#073642"
    set solarized_base01  "#586e75"
    set solarized_base00  "#657b83"
    set solarized_base0   "#839496"
    set solarized_base1   "#93a1a1"
    set solarized_base2   "#eee8d5"
    set solarized_base3   "#fdf6e3"
    set solarized_yellow  "#b58900"
    set solarized_orange  "#cb4b16"
    set solarized_red     "#dc322f"
    set solarized_magenta "#d33682"
    set solarized_violet  "#6c71c4"
    set solarized_blue    "#268bd2"
    set solarized_cyan    "#2aa198"
    set solarized_green   "#859900"

    # This is based roughly on vim's highlighting categories
    set color(Foreground)  "$solarized_base00"
    set color(Background)  "$solarized_base3"
    set color(FGHighlight) "$solarized_base01"
    set color(BGHighlight) "$solarized_base2"
    set color(Comment)     "$solarized_base01"
    set color(Constant)    "$solarized_cyan"
    set color(Identifier)  "$solarized_blue"
    set color(Statement)   "$solarized_green"
    set color(PreProc)     "$solarized_orange"
    set color(Type)        "$solarized_yellow"
    set color(Special)     "$solarized_red"
    set color(Underlined)  "$solarized_violet"
    set color(Error)       "$solarized_red"
    set color(Operator)    "$solarized_orange"

    ctext::clearHighlightClasses $w.t

    # now includes new builtins from Stunt server
    set syntax_moo_code_builtinslist [ list \
        abs acos add_property add_verb asin atan binary_hash binary_hmac \
        boot_player buffered_output_length call_function caller_perms \
        callers ceil children chparent chparents clear_property \
        connected_players connected_seconds connection_name connection_option \
        connection_options cos cosh create crypt ctime db_disk_size \
        decode_base64 decode_binary delete_property delete_verb disassemble \
        dump_database encode_base64 encode_binary equal eval exec exp \
        floatstr floor flush_input force_input function_info generate_json \
        idle_seconds index isa is_clear_property is_member is_player \
        kill_task length listappend listdelete listen listeners listinsert \
        listset log log10 mapdelete mapkeys mapvalues match max max_object \
        memory_usage min move notify object_bytes open_network_connection \
        output_delimiters parent parents parse_json pass players properties \
        property_info queue_info queued_tasks raise random read read_http \
        recycle renumber reset_max_object respond_to resume rindex rmatch \
        seconds_left server_log server_version set_connection_option \
        set_player_flag set_property_info set_task_local set_task_perms \
        set_verb_args set_verb_code set_verb_info setadd setremove shutdown \
        sin sinh sqrt strcmp string_hash string_hmac strsub substitute \
        suspend switch_player tan tanh task_id task_local task_stack \
        ticks_left time tofloat toint toliteral tonum toobj tostr trunc \
        typeof unlisten valid value_bytes value_hash verb_args verb_code \
        verb_info verbs
    ]
    set syntax_moo_code_typeslist [ list INT FLOAT OBJ STR LIST ERR NUM ]
    set syntax_moo_code_variableslist [ list \
        player this caller verb args argstr dobj dobjstr prepstr iobj iobjstr
    ]
    set syntax_moo_code_statementslist [ list \
        except fork while return break continue else elseif endfor \
        endfork endif endtry endwhile finally for if try
    ]
    set syntax_moo_code_constantslist [ list \
        E_ARGS E_INVARG E_DIV E_FLOAT E_INVIND E_MAXREC E_NACC ANY \
        E_NONE E_PERM E_PROPNF E_QUOTA E_RANGE E_RECMOVE E_TYPE E_VARNF E_VERBNF
    ]
    set syntax_moo_code_strings {(\"(?:[^\\\"]|\\.)*\")}
    set syntax_moo_code_comments {(//.*$)}
    set syntax_moo_code_objects {(#-*[0-9]+)}
    set syntax_moo_code_core {(\$[a-zA-Z0-9_]+)}

    ctext::addHighlightClass $w.t Builtins   $color(Identifier) $syntax_moo_code_builtinslist
    ctext::addHighlightClass $w.t Constant   $color(Constant)   $syntax_moo_code_constantslist
    ctext::addHighlightClass $w.t Statement  $color(Statement)  $syntax_moo_code_statementslist
    ctext::addHighlightClass $w.t Type       $color(Type)       $syntax_moo_code_typeslist
    ctext::addHighlightClass $w.t Variable   $color(Type)       $syntax_moo_code_variableslist

    ctext::addHighlightClassForRegexp $w.t String     $color(Constant)   $syntax_moo_code_strings
    ctext::addHighlightClassForRegexp $w.t Comment    $color(Comment)    $syntax_moo_code_comments
    ctext::addHighlightClassForRegexp $w.t Object     $color(Constant)   $syntax_moo_code_objects
    ctext::addHighlightClassForRegexp $w.t Core       $color(Identifier) $syntax_moo_code_core

    ctext::addHighlightClassWithOnlyCharStart $w.t Special $color(Special) $syntax_moo_code_core

    # For unmatched () or if/endif, etc.
    $w.t tag configure syntax_moo_code_unmatched -foreground red -background black

    $w.t configure -foreground $color(Foreground)
    $w.t configure -background $color(Background)
    $w.t configure -linemapfg  $color(FGHighlight)
    $w.t configure -linemapbg  $color(BGHighlight)
}

proc syntax_moo_code.check {w args} {
    global syntax_db

    if { ([ edit.get_type $w ] == "moo-code" ) || ([ $w.t search "@program" 1.0 ] != "") } {
        set syntax_db($w) moo_code
    }
}

############################################################
# syntax_sendmail.tcl
#
# This is a proof-of-concept syntax definition plugin, showing off the three
# procedures that need to exist:  a <name>.start procedure to register the
# edit.load callback for <name>.check and add a menu item to the editor;  a
# <name>.initialize procedure to create the regexen and associated tags,
# and a <name>.check procedure to do the parsing of the editor at
# load-time to see if you want to handle it.
############################################################

client.register syntax_sendmail start

proc syntax_sendmail.start {} {
    edit.add_edit_function "Sendmail Syntax" { syntax.select "sendmail" }
    edit.register load syntax_sendmail.check
}

proc syntax_sendmail.initialize w {

    global syntax_sendmail_headers syntax_sendmail_objects syntax_sendmail_parens

    set syntax_sendmail_headers {^(From:|Subject:|To:|Reply-to:)}
    set syntax_sendmail_objects {(#[0-9]+)}
    set syntax_sendmail_parens {(\(|\))}

    $w.t tag configure syntax_sendmail_headers -foreground darkred
    $w.t tag configure syntax_sendmail_objects -foreground darkgreen
    $w.t tag configure syntax_sendmail_parens -foreground blue
}

proc syntax_sendmail.check {w args} {
    global syntax_db

    if { [ $w.t search "@@sendmail" 1.0 ] != "" } {
        set syntax_db($w) sendmail
    }
}

#
# Changelog:
#
# 2012-05-20 -- 0.2.0 Reboot  - Hack out my hand-rolled syntax-highlighting logic
#                               in favor of using ctext's.  Much faster, much cleaner.
#
# 2002-03-05 -- 0.1.3 New:    - Concept of //-style comments for moocode.
#
# 1999-11-22 -- 0.1.2 Bugfix: - Fixed KeyRelease, Return, and Up/Down bindings
#                               to be {+ <script>} syntax and therefore not
#                               override the editor's default bindings.
#                             - Fix weird problem with Up/Down bindings doing
#                               highlighting on wrong line, causing very strange
#                               wraparound behavior when cursor on last line.
#
# 1999-10-14 -- 0.1.1 Change: - Updated core syntax plugin to work with new
#                               API for the editor's load event in 0.3.21-dev2
#
# 1999-08-27 -- 0.1   New:    - Added <Return>, arrows, and <Button> event
#                               catching so fast typists don't skip clean
#                               over the idle loop.
#                             - Used 0.3.21 load event callback scheme so that
#                               syntax definition plugins can decide at load time
#                               whether they want to handle an editor's text.
#                             - Related: changed the moo-code plugin to detect
#                               either MCP simpleedit 'moo-code' type OR
#                               '@program' at the head of the line, LM-style.
#                             - Added in simple syntax_sendmail.tcl plugin
#                               to demonstrate how it's done - still broken
#                               wrt MCP simpleedit.
#                             - Ugly unmatched () code added.  Not at all
#                               correct yet, but proof-of-concept.
#                     Change: - Moved check_tags code into the core syntax
#                               plugin, to simplify (greatly) the creating
#                               of alternate syntax definitions.  Much more
#                               to be done here, but everything's in the Right
#                               Place(tm) now.
#                             - Removed trailing '_syntax' from all
#                               proc names.  Duh, they're about syntax...
#                             - Reworked regexen to use TCL 8.1 features if
#                               available.  This also fixed a regex bug wrt
#                               8.1.  8.1 is now preferred, tho not required.
#                     Bugfix: - fixed _language bug with highlighting inside
#                               a longer word, ie 'player' in 'the_player'
#                             - each iteration, tags were only being reparsed
#                               from the current cursor to lineend.  Fixed.
#
# 1999-07-18 -- 0.0.4,  Bugfix: - 'strsub' typo
#                               - primitives highlighting even without
#                                 trailing (
#                               - nasty bug with string literals containing
#                                 escaped quotation marks.
#                       Change: - Reformatted these comments ;-)
#                       New:    - Added license info above.
#                               - Added syntax_moo_code_language bit for
#                                 detecting special variables; also, later,
#                                 for language primitives, maybe.
#
# 1999-07-03 -- 0.0.3.2, Bugfix: - editors not created with the Tools->Editor
#                                  menu didn't start up the idle loop.
#
# 1999-06-29 -- 0.0.3.1, Bugfix: - primitives regex leading/trailing chars
#
# 1999-06-28 -- 0.0.3, New:    - use editor's 'load' event from 0.3.20 client.
#                              - removed duplicative "edit.SCcodeedit' procedure.
#                              - changed Andrew's syntax.toggle_syntax to
#                                syntax.select_syntax.
#                              - make individual syntax_<language> plugins add
#                                their name to a global syntax_types list
#                      Change: - much moving things around to separate 'syntax'
#                                core stuff from moo-code-specific stuff.  More
#                                can be done here.
#                              - make all line-based checks into regexen; iterate
#                                through them with the same blort of code instead
#                                of having several only-slightly-different
#                                procedures.
#
#
# 1999-06-08 -- 0.0.2, performance and namespace tweaks from Andrew.  Not
#                            released.
#
# 1999-06-07 -- 0.0.1, first horrible annoying and useless public release.
#
############################################################
