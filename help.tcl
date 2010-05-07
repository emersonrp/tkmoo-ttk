
#
#

set help_subject_list {
    Starting
    Preferences
    Worlds
    Resources
    CommandLine
    Plugins
    Manners
    Features
    SEPARATOR
    About
    LICENCE
}

proc help.text subject {
    global help_subject
    if { [info exists help_subject($subject)] } {
        return $help_subject($subject)
    } elseif { [info procs help.text_$subject] != {} } {
        return [help.text_$subject]
    } {
        return $help_subject(NoHelpAvailable)
    }
}

proc help.show subject {
    global help_subject help_history help_index help_CR
    set h .help
    if { [winfo exists $h] == 0 } {
    toplevel $h
    window.configure_for_macintosh $h

    window.bind_escape_to_destroy $h   

    window.place_nice $h

    $h configure -bd 0

    text $h.t -font [fonts.plain] -wrap word \
	-width 70 \
        -bd 0 -highlightthickness 0 \
        -setgrid 1 \
        -relief flat \
	-bg #fff9e1 \
	-yscrollcommand "$h.s set" \
        -cursor {}

    bind $h <Prior> "ui.page_up $h.t"
    bind $h <Next> "ui.page_down $h.t"

    scrollbar $h.s -command "$h.t yview" \
	-highlightthickness 0
    window.set_scrollbar_look $h.s

    frame $h.controls -bd 0 -highlightthickness 0
    button $h.controls.close -text "Close" -command "destroy $h" -highlightthickness 0

    pack $h.controls -side bottom
    pack $h.controls.close -side left \
	-padx 5 -pady 5

    pack $h.s -fill y -side right
    pack $h.t -expand 1 -fill both 


    $h.t tag configure help_bold 	-font [fonts.bold]
    $h.t tag configure help_italic -font [fonts.italic]
    $h.t tag configure help_fixed -font [fonts.fixedwidth]
    $h.t tag configure help_header \
	-foreground [colourdb.get darkgreen] \
	-font [fonts.header]

    } {
        $h.t configure -state normal
	$h.t delete 1.0 end
    }

    if { [util.eight] == 1 } {
        $h.t tag configure help_paragraph \
	    -lmargin1 10p -lmargin2 10p -rmargin 10p
    }

    set help_CR 0

    help.displayCR

    foreach item [help.text $subject] {
	if { [llength $item] > 1 } {
	    if { [lindex $item 0] == "preformatted" } {
		set formatted $item
		regsub {^preformatted} $item "" formatted
		help.[lindex $item 0] $formatted
	    } {
                help.[lindex $item 0] [lrange $item 1 end]	
	    }
	} {
            help.display "$item "
	}
    }

    $h.t configure -state disabled
    window.focus $h
}

proc help.displayCR { {text ""} {tags ""} } {
    global help_CR
    set h .help
    if { $help_CR == 1 } {
	$h.t insert insert "\n" help_paragraph
    }
    set help_CR 1
    $h.t insert insert $text "help_paragraph $tags"
}

proc help.display { {text ""} {tags ""} } {
    global help_CR
    set h .help
    if { $help_CR == 1 } {
	$h.t insert insert "\n" help_paragraph
    }
    set help_CR 0
    $h.t insert insert $text "help_paragraph $tags"
}

proc help.get_title subject {
    global help_subject
    foreach item [help.text $subject] {
	if { [llength $item] > 1 } {
	    if { [lindex $item 0] == "title"} {
		return [lrange $item 1 end]
	    }
	}
    }
    return $subject
}

proc help.paragraph string {
    help.displayCR
    help.displayCR
}

proc help.bold string {
    help.display "$string" help_bold
    help.display " "
}

proc help.italic string {
    help.display "$string" help_italic
    help.display " "
}

proc help.header string {
    help.displayCR "$string" help_header
    help.displayCR
}

proc help.version null {
    help.display [util.version]
}

proc help.buildtime null {
    help.display [util.buildtime]
}

proc help.title string {
    wm title .help "Help: $string"
}

proc help.preformatted string {
    help.displayCR
    help.displayCR "$string" help_fixed
}

#

proc help.link string {
    if { ([info procs webbrowser.open] != {}) && [webbrowser.is_available] } {
        set tag [util.unique_id "hl"]
        set cmd "webbrowser.open $string"
        help.display "$string" [window.hyperlink.link .help.t $tag $cmd]
        help.display " "
    } {
        help.display "$string"
        help.display " "
    }
}

proc help.subjects {} {
    global help_subject_list
    return $help_subject_list
}

###############################################################################
set help_subject(NoHelpAvailable) {
    {title No Help Avilable}
    {header No Help Available}

    No help text is available for that subject.
}

proc help.text_Plugins {} {
    set text {
    {title Installed Plugins}
    {header Installed Plugins}

    This page displays information about the plugins that have
    been installed with this client.
 
    }

    set dir_info {
    {paragraph foo}
    {header Location of Plugins Directory}
    The client will look for directories to contain plugins in the
    following order.  Only plugins in the first matching directory
    will be loaded.
    }

    if { [info procs plugin.plugins_directories] != {} } {
    set foo {}
    foreach directory [plugin.plugins_directories] {
        lappend foo "    $directory"
    }
    set foo_list [join $foo "\n"]
    set dir_info [concat $dir_info "
        \{preformatted
$foo_list
        \}
    "]
    }
    set text [concat $text $dir_info]

    if { [info procs plugin.plugins_dir] != {} } {
    set dir [plugin.plugins_dir]
    if { $dir == "" } {
        set dir "None of the above directories have been found!!"
    }
    set text [concat $text "
    The client is using the following directory as a source for plugins:
    \{preformatted
    $dir
    \}
    "]
    }

    if { [info procs plugin.plugins_dir] != {} } {

    foreach p [client.plugins] {
        if { [set location [client.plugin_location $p]] != "INTERNAL" } {
            set locations($location) 1
        }
    }

    if { [info exists locations] } {
        set names {}
        foreach name [lsort [array names locations]] {
            lappend names "    $name"
        }
        set plugins_text [join $names "\n"]
    } {
        set plugins_text "    No plugins have been found!!"
    }

    set text [concat $text "
    {header Loaded Plugins}
    The following plugins have been loaded:
    \{preformatted
$plugins_text
    \}
    "]
    }

    return $text
}

set help_subject(Resources) {
    {title Resources File}
    {header Resources File}

    When the client is started it is able to read from an optional
    resources file which contains text entries defining some of
    the client's properties, like display colours and fonts.  For
    the time being only a few colours are definable, but the number
    of configurable options will be improved in future versions of
    the client.  The following entries define the client's default
    colour scheme:

    {preformatted 
    *Text.background: #f0f0f0
    *Entry.background: #f00000
    *desktopBackground: #d9d9d9
    }

    The client looks for your resources file in the following places
    depending on which platform you're using:

    {preformatted
    Platform	Location
    UNIX 	$HOME/.tkmoo-serc
    MAC 	$env(PREF_FOLDER):tkmoo-se.RC
    WINDOWS 	$HOME\tkmoo\tkmoo.res
    }
}

set help_subject(Worlds) {
    {title The worlds.tkm File}
    {header The worlds.tkm File}

    The Worlds Definition File describes the sites that the client
    knows about listing the name, machine host name and port number
    of each site. An {bold optional} username and password can be
    given for each definition which the client will use to connect
    you to your player object. The file contains lines of text laid
    out as follows:

    {preformatted
    World:    <human readable string for the Connections Menu>
    Host:     <host name>
    Port:     <port number>
    Login:    <username>
    Password: <some password>
    ConnectScript: <lines of text to send following connection>
    ConnectScript: ...
    DisconnectScript: <lines of text to send before disconnecting>
    DisconnectScript: ...
    KeyBindings: <keystroke emulation>
    DefaultFont: <font type for main screen, fixedwith or proportional>
    LocalEcho: <On | Off>

    World:    <a different string for a different world>
    Host:     <a different host name>
    Port:     <a different port number>
    ...
    }

    The client looks for the worlds.tkm file in each of the following
    locations depending on the platform you're using, and only data
    from the {bold first} matching file is used by the client:

    {preformatted
    On UNIX		./.worlds.tkm
    			$HOME/.tkMOO-lite/.worlds.tkm
    			$tkmooLibrary/.worlds.tkm

    On Macintosh	worlds.tkm
    			$env(PREF_FOLDER):worlds.tkm
    			$tkmooLibrary:worlds.tkm

    On Windows		.\worlds.tkm
    			$HOME\tkmoo\worlds.tkm
    			$tkmooLibrary\worlds.tkm
    }
}

set help_subject(About) {
    {title About tkMOO-SE}
    {header About tkMOO-SE}

    Version number {version foo} , built {buildtime foo} .
    {paragraph foo}

    tkMOO-SE is Copyright (c) Stephen Alderman
    2003-2006.  All Rights Reserved.

    {paragraph foo}

    {bold tkMOO-SE} is the development of the tkMOO-light client 
    which brang mudding kicking and screaming into the early
    eighties. The client supports a ric graphical user interface,
    and can be extended to implement a wide range of new tools
    for accessing MUDs.

    {paragraph foo}

    Online documentation, programming examples, plugins and developer
    mailing lists can be found on the client's homepage:

    {paragraph foo}
    {link http://www.awns.com/tkMOO-light/}

    {paragraph foo}
    {header Technical Support for tkMOO-SE}

    If you need technical support for tkMOO-SE or would like to
    see some new features designed for the client then please
    contact <info@awns.com>.
}

set help_subject(Starting) {
    {title Getting Started}
    {header Getting Started}

    {bold tkMOO-SE} is a powerful and flexible piece of software
    which you can customise to suit your own needs.  Don't be put off
    by the complexity and all those menu-options because getting
    started is really easy.

    {paragraph foo}
    {header Choosing a world}

    The first thing you'll need to do is choose a mud you'd like
    to visit.  tkMOO-SE lets you define {bold worlds} , each of
    which details the host name and port number of a mud server as
    well as a username, a password and an optional login script.
    You can also define how the client looks when you're in that
    world.

    {paragraph foo}

    The {bold Connect->Worlds...} menu option brings up a list of
    worlds for you to choose from.  Double-clicking on one of the
    entries in the list will connect you to that world.  Notice
    how some of the worlds also appear in the drop-down menu you
    see when you select the {bold Connect} menu option.  You can
    use the {bold Preferences Editor} to add a worlds to this short
    list.

    {paragraph foo}
    {header Adding a world to the list}

    Select the {bold Connect->Worlds...} menu option and click on
    the {bold New} button to create an empty world.  The {bold
    Preferences Editor} will open up ready for you to enter values
    for the world.  You'll need to enter values for the {bold Host}
    and {bold Port} and your {bold Username} and {bold Password}
    if you have one.  Also click on the {bold Add to short list} checkbox.
    When you've finished making changes in the Preferences Editor
    press the {bold Save} button.

    {paragraph foo}

    Now select the {bold Connect} menu option.  Notice how the
    world you've just added now appears in the short list menu?

    {paragraph foo}
    {header Making the connection}

    If your world has been short-listed then just select it from
    the {bold Connect} menu.  You can also select the {bold Connect->Worlds...} 
    menu option and double-click on the relevant entry in the list of worlds.

    {paragraph foo}
    {header Customising the connection}

    tkMOO-SE has been developed to work well with MOO and Cold
    mud servers.  Both of these types of server expect you to log
    in by typing {bold connect <username> <password>} .  When the
    client connects to a server its normal behaviour is to send
    the command:

    {preformatted
    connect <username> <password>
    }

    The client will substitute the values you entered for your
    {bold username} and {bold password} into the command.

    {paragraph foo}

    You'll sometimes want the client to send additional commands
    to the server whenever you connect.  You can put these commands
    in the {bold Connection script} section of the Preferences
    Editor, but if you do this then you'll also need to add the
    'connect' command too.  Here's an example:

    {paragraph foo}

    If you wanted to connect to a MOO and then immediately read the news
    and check your mail then you could put something like this in
    your Connection script.

    {preformatted
    connect %u %p
    news
    @mail
    }

    Your username and password will be substituted automatically
    for the special tokens {bold %u} and {bold %p} .

    {paragraph foo}
    {header The Default World}

    To make things easier for you, the client has a {bold Default
    World} already set up with the most common settings that people
    use.  When the client connects to a world it will use these
    default settings unless you override some of them with new settings
    for that specific world.

    {paragraph foo}
    If you want to make a change that effects all of the worlds
    that the client knows about, then you should edit the settings
    for the default world.

}

set help_subject(Preferences) {
    {title The Preferences Editor}
    {header The Preferences Editor}

    The Preferences Editor has many directives grouped by categories.

    {paragraph foo}
    {header General Settings}

        {bold World}
        {paragraph foo}

	The name of the world you're connecting to.  you can enter
	any value here and the string will be used to help identify
	the mud.  if you use a unique world name then you can use
	it to connect to the world automatically with the {bold
	-world} command line option.  The value you enter here will
	also appear in the short list available from the {bold
	"Connect->Worlds..."} menu item.

        {paragraph foo}
        {bold Host}
        {paragraph foo}

	The host name, or IP address of the mud.

        {paragraph foo}
        {bold Port}
        {paragraph foo}

	The numeric port number of the mud.

        {paragraph foo}
        {bold User name}
        {paragraph foo}

	Your username on the mud.  If you don't enter a value then
	the client will prompt for a username and password when
	you connect to the mud.

        {paragraph foo}
        {bold Password}
        {paragraph foo}

	Your password on the mud.

        {paragraph foo}
        {bold Add to short list}
        {paragraph foo}

	Set this if you want the world to appear in the short list
	available from the {bold Connect->Worlds...} menu item.

        {paragraph foo}
        {bold Local echo}
        {paragraph foo}

	Set this if you want to see the words you type appearing
	hilighted in the output window of the client.  The colour
	of the echoed text is controlled by the {bold Local echo
	colour} directive in the {bold Colours and fonts} category.

        {paragraph foo}
        {bold Input window size}
        {paragraph foo}

	Controls the height of the input window at the bottom of
	the client.

        {paragraph foo}
        {bold Always resize window}
        {paragraph foo}

	When the client connects to a world it will check to see
	if you've saved a preferred window size and position.  If
	you have then the client will reset itself to take on those
	values.  This allows you to have different sized windows
	depending on the mud you're connecting to.

        {paragraph foo}

	You can save the client's current geometry settings by
	selecting the {bold Preferences->Save layout} menu option.

        {paragraph foo}
        {bold Client mode}
        {paragraph foo}

	Mud servers operate in one of two modes, {bold line mode}
	or {bold character mode} .  In line mode a server will send
	lines of text ending in a special end-of-line character.
	In character mode the server may send lines without an
	end-of-line character.  If the server uses command-line
	prompts a lot, or if it asks you a question and the cursor
	stays at the end of the line waiting for you to type your
	answer then the server is probably in character mode.

        {paragraph foo}

	MOO and Cold servers typically operate in line mode and
	many of the special out-of-band protocols that this client
	uses, like XMCP/1.1 and MCP/1.0 will rely upon line-mode
	communication.

        {paragraph foo}

	When in doubt, set this option to {bold line mode} .

        {paragraph foo}
        {bold Write to log file}
        {paragraph foo}

	You can control which of your worlds writes to a logfile
	by setting this toggle.  You'll still need to give a logfile
	name.  The client does not write to a logfile by default.

        {paragraph foo}
        {bold Log file name}
        {paragraph foo}

	The full path to a text file.  If the file doesn't exists
	then it will be created by the client.  If the file already
	exists then new messages will be appended to the file.

        {paragraph foo}
        {bold Connection script}
        {paragraph foo}

	A series of commands, one per line, that the client will
	send to the server immediately after connecting to the
	server.  The client's normal behaviour is to send the
	command {bold connect <username> <password>} but this is
	overriden by any commands you enter in the Connection script
	window.

	{paragraph foo}
	If you wish the client to send a 'connect' command then
	you'll need to add a line explicitly.  Here's an example
	script, the client will substitute the world's username
	and password values for the {bold %u} and {bold %p}
	parameters:

    {preformatted
    connect %u %p
    news
    @mail
    }

        {bold Disconnection script}
        {paragraph foo}

	A series of commands, one per line, that the client will
	send to the server immediately before connecting from the
	server.

	{paragraph foo}
        {bold Key bindings}
        {paragraph foo}

	The client understands several key-bindings that are common
	to other clients or operating-systems. 

    {preformatted
    emacs	standard emacs editor bindings
    tf		standard Tiny Fugue client bindings
    windows	standard Windows 95 bindings
    macintosh	standard Macintosh bindings
    default	standard Tk bindings
    }

    {header Out of Band}

    The client supports several forms of {bold Out of Band} protocol.
    Such protocols define how the client and server can pass complex
    messages to each other and they're usually associated with
    powerful user interfaces like {bold buddy lists} and {bold
    programming environments} .  The 2 main protocols used by the
    client are {bold XMCP/1.1} and the more modern {bold MCP/2.1} .

    {paragraph foo}

    XMCP applications include board-games, maps, whiteboards and
    drag-&-drop desktops.  Many XMCP applications are provided as
    additional {bold plugin} programs you can add to the client.

        {paragraph foo}
        {bold XMCP/1.1 enabled}
        {paragraph foo}

	This toggle controls whether or not the client reponds to
	XMCP messages which may be sent from the server.

	{paragraph foo}
        {bold XMCP/1.1 connection script}
        {paragraph foo}

	A series of commands, one per line, that the client will
	send to the server once an XMCP authentication code has
	been set.

        {paragraph foo}
        {bold Use MCP/2.1}
        {paragraph foo}

	This toggle controls whether or not the client reponds to
	MCP/2.1 messages which may be sent from the server.

        {paragraph foo}
        {bold Use MCP/1.0}
        {paragraph foo}

	This toggle controls whether or not the client reponds to
	MCP/1.0 messages which may be sent from the server.

    {paragraph foo}
    {header Colours and Fonts}

    The client is able to display text in a range of font styles
    and colours.  You can chose the overriding style of font
    displayed for each world by setting the {bold Default font
    type} option.

        {paragraph foo}
        {bold Normal text colour}
        {paragraph foo}

	Click on the long coloured bar to open a colour-chooser
	dialog box.  This option sets the foreground text colour
	for the main output window.

        {paragraph foo}
        {bold Background colour}
        {paragraph foo}

	This option sets the background colour for the main output window.

        {paragraph foo}
        {bold Local echo colour}
        {paragraph foo}

	This option sets the foreground colour for locally echoed
	text.  Local echo behaviour is controlled by the {bold
	Local echo} option under General Settings.

        {paragraph foo}
        {bold Default font type}
        {paragraph foo}

	This option controls the general look of the main display
	font, either fixedwidth or proportional.

        {paragraph foo}
        {bold Fixedwidth font}
        {paragraph foo}

	This option controls the font used for all fixedwidth text
	displayed on the output window.

        {paragraph foo}
        {bold Proportional font}
        {paragraph foo}

	This option controls the font used for all proportional text
	displayed on the output window.

        {paragraph foo}
        {bold Bold font}
        {paragraph foo}

	This option controls the font used for all bold text
	displayed on the output window.

        {paragraph foo}
        {bold Italic font}
        {paragraph foo}

	This option controls the font used for all italic text
	displayed on the output window.

        {paragraph foo}
        {bold Header font}
        {paragraph foo}

	This option controls the font used for all headings displayed
	on the output window.  At the moment any headings are also
	displayed in green.

    {paragraph foo}
    {header Paragraph Layout}

    Lines of text can be displayed as plain text (no margins or
    indentation), or with left and right margins, and extra
    indentation for text that wraps round the end of a line.

    {preformatted
|<- full width of output window  ------------------------------->|
|<- left ->|                                         |<- right  >|
           This is a long sentence which the client
                        will automatically wrap over 
                        several lines.  If the text
                        wraps over two or more lines
                        then the additional lines are
                        indented.  This helps to make
                        the text easier to read.
           |<- indent ->|
    }

    You can also control the spacing above or below a line of text.
    If a line wraps round to produce several formatted lines of
    text on the screen then the space between the screen lines can
    also be controlled.

        {paragraph foo}
	{bold Display paragraphs}
        {paragraph foo}

	Setting this toggle causes paragraphs of text to be displayed
	according to the following settings.

        {paragraph foo}
	{bold Distance units}
        {paragraph foo}

	All the paragraph settings can be in units of pixels,
	millimeters or characters.

        {paragraph foo}
	{bold Left margin}
        {paragraph foo}

	The distance from the left edge of the screen to the first
	character in the paragraph.

        {paragraph foo}
	{bold 2nd line indent}
        {paragraph foo}

	If the paragraph is longer than the width of the screen
	then the line will be wrapped.  The second line and subsequent
	lines in the paragraph will be indented but this amount.

        {paragraph foo}
	{bold Right margin}
        {paragraph foo}

	The distance from the right edge of the screen to the
	characters in the paragraph.

        {paragraph foo}
	{bold Space above}
        {paragraph foo}

	The amount of space displayed above the first line in a
	paragraph.

        {paragraph foo}
	{bold Space between}
        {paragraph foo}

	The amount of space displayed between each line in the body
	of a paragraph.

        {paragraph foo}
	{bold Space below}
        {paragraph foo}

	The amount of space displayed below the last line in a
	paragraph.

}

set help_subject(Manners) {
    {title How to behave on a MUD}
    {header How to behave on a MUD}

    Each MUD you visit will have its own distinct character and
    set of social rules for moderating behaviour.  Some places are
    very formal and others are anarchistic.  The one thing all MUDs
    have in common is that {bold REAL LIVE PEOPLE} are connected
    to the players, and users you will meet.  Here are some general
    guidelines for getting along with people when you visit a new
    MUD.

    {paragraph foo}

    {header Be polite.  Avoid being rude}

    The MUD is worth participating in because it is a pleasant
    place for people to be.  When people are rude or nasty to one
    another, it stops being so pleasant.  

    {paragraph foo}

    {header Respect other player's sensibilities}

    The participants on the MUD come from a wide range of cultures
    and backgrounds.  Your ideas about what constitutes offensive
    speech or descriptions are likely to differ from those of other
    players.  Please keep the text that players can casually run
    across as free of potentially-offensive material as you can.
    If you want to build objects or areas that are likely to offend
    some segment of the community, please give sufficient warning
    to the casual explorer so that they can choose to avoid those
    objects or areas.

    {paragraph foo}

    {header Don't spoof}

    Spoofing is loosely defined as `causing misleading output to
    be printed to other players.'  For example, it would be spoofing
    for anyone but Munchkin to print out a message like `Munchkin
    sticks out his tongue at Potrzebie.'  This makes it look like
    Munchkin is unhappy with Potrzebie even though that may not be
    the case at all.  Please be aware that, while it is easy to
    write MUD programs that spoof, it is usually easy to detect
    such spoofing and correctly trace it to its source.

    {paragraph foo}

    {header Don't shout}

    It is easy to write a MUD command that prints a message to
    every connected player in the MUD.  Please don't.  It is
    generally annoying to receive such messages; such shouting
    should be reserved for really important uses, like wizards
    telling everyone that the server is about to be shut down.
    Non-wizards never have a good enough reason to shout.  Use
    `page' instead.

    {paragraph foo}

    {header Only teleport your own things}

    By default, most objects (including other players) allow
    themselves to be moved freely from place to place within the
    MUD.  This fact makes it easier to build useful objects like
    exits and magic rings that move things as a part of their normal
    role in the virtual reality.  Unfortunately, it also makes it
    easy to move other players from place to place without their
    permission, or to move objects in and out of other players'
    possession.  Please don't do this; it's annoying (at the least)
    to the poor victim and can only cause bad feelings.
}

set help_subject(LICENCE) {
    {title LICENCE}
    {header LICENCE}
tkMOO-SE is Copyright (c) Stephen Alderman 2003-2006.

	All Rights Reserved.

    {paragraph foo}

Permission is hereby granted to use this software for private, academic
and non-commercial use. No commercial or profitable use of this
software may be made without the prior permission of the author.
    {paragraph foo}

THIS SOFTWARE IS PROVIDED BY Stephen Alderman``AS IS'' AND ANY
EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL ANDREW WILSON BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
}

set help_subject(CommandLine) {
    {title Command Line Options}
    {header Command Line Options}

The client currently supports the following command line options,
{bold %} is your system prompt, optional arguments appear inside
braces.

{paragraph foo}     
{bold % tkmoo {-dir <directory>} {<host> {<port> default 23}} }
{paragraph foo}     

	Use it either from the command line or perhaps set up your
	web browser to use the client as the 'telnet' application
	when processing telnet URLs.  Telnet URLs can be bound to
	a command like 'tkmoo %h %p'.  When using a web browser
	like Netscape, %h and %p are translated to the telnet URL's
	host and port number respectively.

{paragraph foo}

	'<directory>' is the name of a directory containing the
	client's resource files, worlds.tkm and triggers.tkm files
	and /plugins/ directory.

{paragraph foo}     

	When no command line options are present, the client will
	start up and wait for you to select menu options.

{paragraph foo}     
{bold % tkmoo {-dir <directory>} -world <some unique substring>}
{paragraph foo}     

	The client will search for a world with a Name containing
	the substring.  If a unique world is present in your
	worlds.tkm file then the client will try to connect to it.
	If there are several worlds matching the substring then
	the client will display a list of the matching worlds, but
	will not attempt to connect to any of them.

{paragraph foo}     
{bold % tkmoo {-dir <directory>} -f <some file name>}
{paragraph foo}     

	The client assumes that the file is in the same format as
	the worlds.tkm file and contains a single world's definitions.
	The client will read the file and attempt to connect to
	the world defined there.

{paragraph foo}

        You can use this funtionality to create URLs to a .tkm
        file.  Make your webserver send a special mime-type when
	you download the file and teach your web browser to launch
	the client when it receives such a file.

{paragraph foo}

	A mime type like 'application/x-tkm' could be bound it to
	the command 'tkmoo -f %s'.  When using a web browser like
	Netscape, %s is translated to the downloaded file's name.

}
set help_subject(Features) {
    {title NEW FEATURES}
    {header New Features For splinters edition}
    
TkMOO-splinters edition (TkMOO-SE) has many new features for making 
MOOing easier.

{paragraph foo}

	Basicly TkMOO-SE has all the useful plugins as standard and
	includes many triggers to use them. For these to work you need
	to copy the text in triggers.new into triggers.tkm (replace the
	whole lot as it starts with the same stuff).
	
{paragraph foo}

	So now that is setup the following is an explanation of what the
	new features of TkMOO SE does.
	
{paragraph foo}

	There is the implentation of subwindows so all pages and channels
	are sent to the windows and you can talk to people easier and with
	all the text in one window (no more scrooling to see what was last
	said). you can also reply back using the text box provided
	
{paragraph foo}
	
	if you have beeen beeped by a player then you now have a popup
	displayed telling you.
	
{paragraph foo}
	
	If you use a compass you now don't have to type 'go <exit>' 
      all you have to do is sit back and 	relax 
      (there is a delay so it does not lag the MOO).
	
{paragraph foo}
	
	Many of these features have made my MOOing easier and more enjoyable
	I hope they do to you too.
	
{paragraph foo}
	
	Splinter98 (find him at pythonmoo.co.uk:1111 as splinter98 (#224))

}
