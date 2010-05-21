#
#       tkMOO
#       ~/.tkMOO-lite/plugins/toolbar.tcl
#
# toolbar.tcl is Copyright (c) Joshua May <joshua@paxhaven.net> 1999, 2000
# 
#	All Rights Reserved
#
# Permission is hereby granted to use this software for private, academic
# and non-commercial use. No commercial or profitable use of this
# software may be made without the prior permission of the author.
# 
# THIS PLUGIN IS PROVIDED BY JOSHUA MAY ``AS IS'' AND ANY
# EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT JOSHUA MAY BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS PLUGIN, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# Adds customizable toolbar buttons to tkMOO-light.

client.register toolbar start
client.register toolbar client_connected
client.register toolbar client_disconnected

proc toolbar.start {} {

    preferences.register toolbar {Toolbar Settings} {
        { {directive ShowClientToolbar}
            {type boolean}
            {default On}
            {display "Display main toolbar"} }
        { {directive ToolBarFont}
            {type font}
            {default "helvetica 12 bold roman"}
            {default_if_empty}
            {display "Toolbar font"} }
        { {directive ToolBarRosetteFont}
            {type font}
            {default "helvetica 10 bold roman"}
            {default_if_empty}
            {display "Rosette font"} }
        { {directive UseToolBarRosette}
            {type boolean}
            {default Off}
            {display "Display rosette"} }
        { {directive UseGraphicalRose}
            {type boolean}
            {default Off}
            {display "Use graphical rosette"} }
        { {directive UseDialogRose}
            {type boolean}
            {default On}
            {display "Use rosette window"} }
        { {directive DigByDefault}
            {type boolean}
            {default Off}
            {display "Dig by default"} }
        { {directive DigReturnByDefault}
            {type boolean}
            {default On}
            {display "Dig return exit"} }
        { {directive DigCloseOnCompletion}
            {type boolean}
            {default On}
            {display "Close on completion"} }
        { {directive DigFollowNewExit}
            {type boolean}
            {default On}
            {display "Follow new exit"} }
        { {directive RosetteDigCmd}
            {type string}
            {default "@dig"}
            {default_if_empty}
            {display "Dig command"} }
        { {directive UseEditToolBar}
            {type boolean}
            {default Off}
            {display "Display editor toolbar"} }
        { {directive ToolBarStyle}
            {type choice-menu}
            {default raised}
            {choices {raised sunken flat solid}}
            {display "Button style"} }
        { {directive UseCustomToolbarColors}
            {type boolean}
            {default Off}
            {display "Use custom colors"} }
        { {directive TBButtonBG}
            {type colour}
            {default grey85}
            {display "Normal background"} }
        { {directive TBButtonFG}
            {type colour}
            {default black}
            {display "Normal foreground"} }
        { {directive TBButtonABG}
            {type colour}
            {default grey95}
            {display "Active background"} }
        { {directive TBButtonAFG}
            {type colour}
            {default black}
            {display "Active foreground"} }
        { {directive TBPadY}
            {type updown-integer}
            {default 0}
            {display "Vertical padding"}
            {low 0}
            {high 10} }
        { {directive TBPadX}
            {type updown-integer}
            {default 0}
            {display "Horizontal padding"}
            {low 0}
            {high 10} }
          { {directive UseToolBar}
              {type boolean}
              {default Off}
              {display "Display custom toolbar"} }
          { {directive TBbutton1Name}
              {type string}
              {default ""}
              {display "Button 1 (Name)"} }
          { {directive TBbutton1Action}
              {type string}
              {default ""}
              {display "Button 1 (Action)"} }
          { {directive TBbutton1Align}
              {type choice-menu}
              {default left}
              {choices {left right}}
              {display "Button 1 (Alignment)"} }
          { {directive TBbutton2Name}
              {type string}
              {default ""}
              {display "Button 2 (Name)"} }
          { {directive TBbutton2Action}
              {type string}
              {default ""}
              {display "Button 2 (Action)"} }
          { {directive TBbutton2Align}
              {type choice-menu}
              {default left}
              {choices {left right}}
              {display "Button 2 (Alignment)"} }
          { {directive TBbutton3Name}
              {type string}
              {default ""}
              {display "Button 3 (Name)"} }
          { {directive TBbutton3Action}
              {type string}
              {default ""}
              {display "Button 3 (Action)"} }
          { {directive TBbutton3Align}
              {type choice-menu}
              {default left}
              {choices {left right}}
              {display "Button 3 (Alignment)"} }
          { {directive TBbutton4Name}
              {type string}
              {default ""}
              {display "Button 4 (Name)"} }
          { {directive TBbutton4Action}
              {type string}
              {default ""}
              {display "Button 4 (Action)"} }
          { {directive TBbutton4Align}
              {type choice-menu}
              {default left}
              {choices {left right}}
              {display "Button 4 (Alignment)"} }
     }


    set d_north { R0lGODlhFQAVAPEAAAAAAIAAAP8AAL29vSH5BAEAAAMALAAAAAAVABUAAAI3nI+pe8FvgnBQ
STErujhr3nkPGIpWiVIJiWJqFMRyJ9cQ9360tu185PvhfkAXcTAk1nLHppNYAAA7 }
    set d_northeast { R0lGODlhFQAVAPEAAAAAAIAAAP8AAL29vSH5BAEAAAMALAAAAAAVABUAAAIunI+py+0Po1yh
WhuD2DxIzQneF44Q2GXdZjaop7VUalTOm8hKPCF6DwwKh8RBAQA7 }
    set d_northwest { R0lGODlhFQAVAPEAAAAAAIAAAP8AAL29vSH5BAEAAAMALAAAAAAVABUAAAIsnI+py+0Po0yh
WguD2DxEzQneF45kKYGgSHqr2VTH+8ADPd1sbtj8DwwKIQUAOw== }
    set d_west { R0lGODlhFQAVAPEAAAAAAIAAAP8AAL29vSH5BAEAAAMALAAAAAAVABUAAAI3nI+py63hWoDx
CVpPEDdr3nkbiEUjOaVpcoKuW7bvXA7yTFqwqi5tbcp5DCNgZWM8Jo/DpjNRAAA7 }
    set d_home { R0lGODlhFQAVAPIAAAAAAIAAAP8AAP//AP///729vQAAAAAAACH5BAEAAAUALAAAAAAVABUA
AANFWLrc/jDK+QKtwgZ7g/gbN3kfKEZkCY5qezZhLL9MQNw4TtcE4OeE3cIGGACAQgXx5zsm
C7Zc0SmJ4qbB6ix26Xq/4G4CADs= }
    set d_east { R0lGODlhFQAVAPEAAAAAAIAAAP8AAL29vSH5BAEAAAMALAAAAAAVABUAAAI4nI+py83hXIBx
BUErulhvAWYaF1rTeYKqaJDq+7IuTIszvSboDrON6/vlPANOUNIhto4RpvLZKAAAOw== }
    set d_south { R0lGODlhFQAVAPEAAAAAAIAAAP8AAL29vSH5BAEAAAMALAAAAAAVABUAAAI3nI+py+2fgpQQ
BYFDPTdv0wnaF45b+Q0oiYnOBLfwFLX27Soh7jH7bfLxgo0f8SVLqXLKo5JRAAA7 }
    set d_southwest { R0lGODlhFQAVAPEAAAAAAIAAAP8AAL29vSH5BAEAAAMALAAAAAAVABUAAAIsnI+py+0Po4xh
oiCq0weLvHEeuIEj13gn9bVo6U7j96ZtDAX6vlv+DwwKBwUAOw== }
    set d_southeast { R0lGODlhFQAVAPEAAAAAAIAAAP8AAL29vSH5BAEAAAMALAAAAAAVABUAAAIsnI+py+0Po1xh
oiCqxSIn3XCeEYBh52Hm2XEri77wCIltZN9PyffWDwwKhQUAOw== }
    set d_up { R0lGODlhFQAVAPIAAAAAAIAAAP8AAICAgL29vQAAAAAAAAAAACH5BAEAAAQALAAAAAAVABUA
AANFSLrc/jDKSQN9Qdi7stAc4X1gAwDL2ZUOihKukm3taTMz9Cq7GNAmRm/SG0pst8tpwByo
iM5m1GiKNgFOChLJ2VJD4FACADs= }
    set d_down { R0lGODlhFQAVAPIAAAAAAIAAAP8AAICAgL29vQAAAAAAAAAAACH5BAEAAAQALAAAAAAVABUA
AANESLrc/jDKOYOlLoiAm+bd8kEAsJSEJqybY5rEm7JgU96wMj557EW93iQYwqEwpYFycJQA
mEuo0AVdPqcuY3NoDHm/jQQAOw== }
    set d_in { R0lGODlhFQAVAPIAAAAAAAD//4AAAP8AAIAAgP8A////AL29vSH5BAEAAAcALAAAAAAVABUA
AANVeLrc/jDKCKq9ExASugdZUWxeAEqAKHLdSanjxwhOqrLmIgw1jJ+7gWBIO9gMht8hOGgK
FbaVbNkkFqOxlo7XwCp1vdv0NcLlUKTSmXJpT97wuBySAAA7 }
    set d_out { R0lGODlhFQAVAPIAAAAAAAD//4AAAP8AAIAAgP8A////AL29vSH5BAEAAAcALAAAAAAVABUA
AANVeLrc/jDKCKq9ExASugdZUWxeAEqAKHLdSanj1whNqrJmM9CLvcqCoGCw64kMBhxoSGzy
fLHWQcjkHaBKnfUKyzK23JsMtcLlUKTSmXJpT97wuBySAAA7 }

    image create photo i_north     -format GIF87 -data $d_north
    image create photo i_northwest -format GIF87 -data $d_northwest
    image create photo i_northeast -format GIF87 -data $d_northeast
    image create photo i_west      -format GIF87 -data $d_west
    image create photo i_home      -format GIF87 -data $d_home
    image create photo i_east      -format GIF87 -data $d_east
    image create photo i_south     -format GIF87 -data $d_south
    image create photo i_southwest -format GIF87 -data $d_southwest
    image create photo i_southeast -format GIF87 -data $d_southeast
    image create photo i_up        -format GIF87 -data $d_up
    image create photo i_down      -format GIF87 -data $d_down
    image create photo i_in	       -format GIF87 -data $d_in
    image create photo i_out       -format GIF87 -data $d_out

    set d_open { R0lGODlhEAAQAPIAAAAAAICAAICAgMPDw729vQAAAAAAAAAAACH5BAEAAAQALAAAAAAQABAA
AAM/SLrcCwRA16SakUosB9bAMATBVoUj2XEoWbZc+oouJoQl7ZbLPeI7Sy8EfAkEDB9OcqTc
Nk0K4RmVKqrW7CIBADs= }
    set d_save { R0lGODlhEAAQAPIAAAAAAFhYWMDAAICAgP///729vQAAAAAAACH5BAEAAAUALAAAAAAQABAA
AANCWLrcCzBKyIAAJGsLxrvadnkKF2YcWZhn+mHt+E6QXAp4rnezFAS21WU06AyCHKIROTQu
eYoiTaIqDK7Y7NXBZSQAADs= }
    set d_saveas { R0lGODlhEAAQAPIAAAAAAMDAAICAgP///729vQAAAAAAAAAAACH5BAEAAAQALAAAAAAQABAA
AANDSLrcCjBKBwIYeFQg2s6a1TGbZAJLaYHbWFlr1j7WJ4s0VEs4oQbAYE8Q2UEEPYKACONw
kjnRk9Mgno6OpXY7cngVCQA7 }
    set d_pref { R0lGODlhEAAQAMIAAICAgP///wAAAFhYWP///////////////yH5BAEKAAQALAAAAAAQABAA
AANDSLrc3gC8GBUIQS5xce6foAhYFAxDpnIE6Z1pGbAkBasX/d6ybqOenMTlAdp8FBRF2FoC
BJwlDUqNUKuWZdb56Hq7CQA7 }
    set d_worlds { R0lGODlhEAAQAOMAAFhYWABz/wAA/wD/AAAAAADAAACAAAAAwP//////////////////////
/////////yH+LE1hZGUgd2l0aCBLSWNvbkVkaXQgZm9yIExIVGVjaCBieSBKb3NodWEgTWF5
ACH5BAEKAAgALAAAAAAQABAAAARXEEkJap2YgsD5zVsgjMJgEthmDuRQFAZKuTBZwjJAG/bo
xghdrWV6AYU838t4HBiSN6PggNoIoLcklSKy/aay4KH3HG0nhMPYpg6j0+q2O0Oo1zP4PCYC
ADs= }
    set d_exit { R0lGODlhEAAQAPEAAAAAAP8A/////729vSH5BAEAAAMALAAAAAAQABAAAAI3nI9pwO0KAhOU
AhjytDhrnkSeBA6XOZLCySwpwD1iIKgs+5b4CK+d1zshGLyGYiESHg+tpfNYAAA7 }
    set d_disc { R0lGODlhEAAQAPIAAAAAAIAAAMAAAP8AAICAgL29vQAAAAAAACH5BAEAAAUALAAAAAAQABAA
AAM7WLrcS8QVyIgYsQ6RZ7gdsQUh8WHTSD0mqHbsKZBw1dKSIs5gvpOnWmoGaaEer4kxRCx9
YMVGNEetShIAOw== }
    set d_editor { R0lGODlhEAAQAMIAAAAAAIAAAKCgoP//////AICAAMPDw////yH5BAEKAAcALAAAAAAQABAA
AAM2eLrc/gA8B0KQUwFhsY4LMGze4UkiUZSlOagt+65UOLeadpt1SvM5E8AA+H1OQ2ImBFo6
n5kEADs= }
    set d_log { R0lGODlhEAAQAPIAAAAAAACAAAD/AIAAAMAAAICAgL29vQAAACH5BAEAAAYALAAAAAAQABAA
AAM/aLrcHi6aIBi4TwRoAPlAs4UdMZxA4VzeYA5p1J6wugJ0LRO4Ga8v16/R+uhuOJRthTrK
UMNIgbWUGApYqyIBADs= }
    set d_triggers { R0lGODlhEAAQAPIAAAAAAFhYWAAA/4CAgKCgoP///729vQAAACH5BAEAAAYALAAAAAAQABAA
AANAaLrc/m3ISecaIustwFADIY4k4YFFqq7FaQxFIMdz0H4vq7uwLfu2G0q34tFqPmGOqHIB
ntAoFPeqWKmQrHaRAAA7 }
    set d_rosette { R0lGODlhEAAQAPEAAAAAAAAAgL29vQAAACH5BAEAAAIALAAAAAAQABAAAAInlC+Bu+HMnISR
xkdV2lqb131JJ5UmBoqct3Et22DWAWfl/Ml4jUMFADs= }
    set d_toolbar { R0lGODlhEAAQAPIAAAAAAFhYWAAA/4CAgKCgoP/AwP///729vSH5BAEAAAcALAAAAAAQABAA
AAM6eLrc/jC+QasdCqghuvdBpg1EaZrhAazkeabrMRh0XcObrafLrN8N38/A2xSOSGRRFmg6
n5KodLpIAAA7 }
    set d_cut { R0lGODlhEAAQAPIAAAAAAAAA/4CAgP///729vQAAAAAAAAAAACH5BAEAAAQALAAAAAAQABAA
AAM7SLrc/g9AIhmo7eaBFeCN8GGj4IhgCaHqxJoTdV0C3AQ4IOKBrfSC3q8mXAiLR18QqFjW
Qs9FzRdjJAAAOw== }
    set d_copy { R0lGODlhEAAQAPEAAAAAAICAgP///729vSH5BAEAAAMALAAAAAAQABAAAAI1nI95wKwJhHTP
xClAHTe32klZ8IQNhZgiaonZmqVndyLBHYQTqehj6doBgwAeZMYwJnDMQAEAOw== }
    set d_paste { R0lGODlhEAAQAPIAAAAAAICAAICAgMPDw///wP///729vQAAACH5BAEAAAYALAAAAAAQABAA
AANGaLrcbiA+FSupcoHAARnD1mndB4adQHVYlK5cLAeACs0tbYsxUPyVHe5X8NVgPSJGxesQ
lbvWE2gzCK4C3/ToaAUn2LAgAQA7 }
    set d_macmoose { R0lGODlhEAAQAPIAAAAAAFhYWAAA/4CAgKCgoP/AwP///729vSH5BAEAAAcALAAAAAAQABAA
AANFeLrc/m3ISecaIustwFBVOHggUZwooRLkIVbtYMwGIdPs5xpBUMu9Woz2I+ZAPJ8tKdTd
ZkvcEPdsKgDYrDarc70okHACADs= }
    set d_editsel { R0lGODlhEAAQAPMAAAAAAFhYWAAA//8AAICAgKCgoMPDw////729vQAAAAAAAAAAAAAAAAAA
AAAAAAAAACH5BAEAAAgALAAAAAAQABAAAARREEiJqr0InE3rGJjGHQACmpdITt5nqRtJeGkc
AzOWcVPf76SCYEgUFAqlnmHJbOIQBALMxsntAtjAISt7UanPiga75XbFX1s442tbodG4PBoB
ADs= }
    set d_find { R0lGODlhEAAQAPIAAAAAAAAA/wD//4CAgP///729vQAAAAAAACH5BAEAAAUALAAAAAAQABAA
AAMzWLrc/hBIABcgAtNIehabA3wYETYXCUaqCQ1jKVXwBARnM+z7nb++CgOGEy5qxuMg6UgA
ADs= }
    set d_goto { R0lGODlhEAAQAPEAAAAAAP8AAICAgL29vSH5BAEAAAMALAAAAAAQABAAAAIwnI+pyw2egGDg
HUmDHdjUDwSaN3nieT4dB4batAqyHHZrtN7IrR/l9WuQhIkg0VAAADs= }

    image create photo i_open     -format GIF87 -data $d_open
    image create photo i_save     -format GIF87 -data $d_save
    image create photo i_saveas   -format GIF87 -data $d_saveas
    image create photo i_pref     -format GIF87 -data $d_pref
    image create photo i_worlds   -format GIF87 -data $d_worlds
    image create photo i_exit     -format GIF87 -data $d_exit
    image create photo i_disc     -format GIF87 -data $d_disc
    image create photo i_editor   -format GIF87 -data $d_editor
    image create photo i_log      -format GIF87 -data $d_log
    image create photo i_triggers -format GIF87 -data $d_triggers
    image create photo i_rosette  -format GIF87 -data $d_rosette
    image create photo i_toolbar  -format GIF87 -data $d_toolbar
    image create photo i_cut      -format GIF87 -data $d_cut
    image create photo i_copy     -format GIF87 -data $d_copy
    image create photo i_paste    -format GIF87 -data $d_paste
    image create photo i_macmoose -format GIF87 -data $d_macmoose
    image create photo i_editsel  -format GIF87 -data $d_editsel
    image create photo i_find     -format GIF87 -data $d_find
    image create photo i_goto     -format GIF87 -data $d_goto

    window.menu_tools_add "Main toolbar on/off" toolbar.client_toolbar_toggle
    window.menu_tools_add "Custom toolbar on/off" toolbar.toolbar_toggle
    window.menu_tools_add "Rosette on/off" toolbar.rosette_toggle

    edit.add_edit_function "Toolbar on/off" { toolbar.toggle_editorbar }
    edit.register load toolbar.load_editorbar

    set use [worlds.get_generic On {} {} ShowClientToolbar]
    if { [string tolower $use] == "on" } { toolbar.create_client_toolbar }

### Ignore this section of code, I got bored one day and made a QuickConnect bar,
### It doesn't serve any actual function so it's commented out.
#
#        { {directive ShowQuickConnectToolbar}
#            {type boolean}
#            {default Off}
#            {display "Display QuickConnect"} }
#    window.menu_tools_add "QuickConnect bar on/off" toolbar.quickconnect_toggle
#    set use [worlds.get_generic Off {} {} ShowQuickConnectToolbar]
#    if { [string tolower $use] == "on" } { toolbar.create_quickconnect }
#
}

proc toolbar.client_connected {} {
    set use [worlds.get_generic On {} {} UseToolBar]
    if { [string tolower $use] == "on" } { toolbar.create }

    set use [worlds.get_generic Off {} {} UseToolBarRosette]
    if { [string tolower $use] == "on" } { toolbar.create_rosette }
}

proc toolbar.client_disconnected {} {
    toolbar.destroy
    toolbar.destroy_rosette
}

proc toolbar.destroy {} {
    if { [winfo exists .toolbar] == 1 } {
        window.remove_toolbar .toolbar
        destroy .toolbar
    }
}

proc toolbar.create {} {
    if { [winfo exists .toolbar] == 1 } { return }

    ttk::frame .toolbar

    set tbfont [worlds.get_generic {} {} {} ToolBarFont]

    set tbstyle [worlds.get_generic {} {} {} ToolBarStyle]

    set buttonbg [worlds.get_generic {} {} {} TBButtonBG]
    set buttonfg [worlds.get_generic {} {} {} TBButtonFG]
    set buttonabg [worlds.get_generic {} {} {} TBButtonABG]
    set buttonafg [worlds.get_generic {} {} {} TBButtonAFG]

    set tbpady [worlds.get_generic {} {} {} TBPadY]
    set tbpadx [worlds.get_generic {} {} {} TBPadX]

    foreach button {1 2 3 4 5 6 7 8 9 10 11 12} {
        set name [worlds.get_generic {} {} {} TBbutton${button}Name]
        set action [worlds.get_generic {} {} {} TBbutton${button}Action]
        set align [worlds.get_generic {} {} {} TBbutton${button}Align]
        if { $name != "" } {
            ttk::button .toolbar.button${button} \
                -text $name -command "client.outgoing {$action}"
            pack .toolbar.button${button} -side $align \
                -padx $tbpadx -pady $tbpady
            set_balloon .toolbar.button${button} "$name"     
        }
    }
    window.add_toolbar .toolbar
    window.repack
}

proc toolbar.toolbar_toggle {} {
    if { [winfo exists .toolbar] == 1 } { toolbar.destroy } { toolbar.create }
}

proc toolbar.create_quickconnect {} {
    if { [winfo exists .quickconn] == 1 } { return }

    ttk::frame .quickconn

    set tbstyle [worlds.get_generic {} {} {} ToolBarStyle]

    label .quickconn.label -text "QuickConnect:  "
    entry .quickconn.host -width 25 \
        -background [colourdb.get pink] \
        -font [fonts.fixedwidth]
    entry .quickconn.port -width 8 \
        -background [colourdb.get pink] \
        -font [fonts.fixedwidth]
    ttk::label .quickconn.sep -width 1
    ttk::button .quickconn.connect -text "Connect" -command "toolbar.quickconnect"
    ttk::button .quickconn.clear -text "Clear" -command "toolbar.clear_quickconnect"
    ttk::button .quickconn.close -text "Hide" -command "toolbar.destroy_quickconnect"

    bind .quickconn.host <Return> "toolbar.quickconnect"
    bind .quickconn.port <Return> "toolbar.quickconnect"

    foreach qcpack {label host port sep connect clear close} {
        pack .quickconn.${qcpack} -side left }

    window.add_toolbar .quickconn
    window.repack
}

proc toolbar.destroy_quickconnect {} {
    if { [winfo exists .quickconn] == 1 } {
        window.remove_toolbar .quickconn
        destroy .quickconn
    }
}

proc toolbar.quickconnect_toggle {} {
    if { [winfo exists .quickconn] == 1 } { toolbar.destroy_quickconnect } { toolbar.create_quickconnect }
}

proc toolbar.clear_quickconnect {} {
    .quickconn.host delete 0 end
    .quickconn.port delete 0 end
}

proc toolbar.quickconnect {} {
    set qchost [.quickconn.host get]
    set qcport [.quickconn.port get]
    if { $qchost != "" && $qcport != "" } {
        toolbar.clear_quickconnect
        window.focus .input
        catch { wm title . "$qchost:$qcport - tkMOO-light" }
        window.displayCR "--> QuickConnect to $qchost on port $qcport" window_highlight
        client.connect $qchost $qcport
    } else {
        window.displayCR "--> Host or port missing" window_highlight
    }
}

proc toolbar.create_rosette {} {
    if { [winfo exists .rosettetb] == 1 } { return }

    set tbfont [worlds.get_generic {} {} {} ToolBarRosetteFont]

    set tbstyle [worlds.get_generic {} {} {} ToolBarStyle]

    set buttonbg [worlds.get_generic {} {} {} TBButtonBG]
    set buttonfg [worlds.get_generic {} {} {} TBButtonFG]
    set buttonabg [worlds.get_generic {} {} {} TBButtonABG]
    set buttonafg [worlds.get_generic {} {} {} TBButtonAFG]

    set use [worlds.get_generic Off {} {} UseGraphicalRose]
    if { [string tolower $use] == "on" } { set rose_width 0 } { set rose_width 12 }

    set sep_width 1

    set r .rosettetb

    set rosedialog [worlds.get_generic On {} {} UseDialogRose]
    if { [string tolower $rosedialog] == "on" } {
        catch { destroy .rosettetb }
        toplevel $r
        wm title $r "Rosette"
#        wm resizable $r 0 0
    } else {
        frame $r -bd 2 -relief groove
    }

    ttk::frame $r.l

    ttk::frame $r.l.top

    foreach topdir {Northwest North Northeast In Up} {
        set wname [string tolower $topdir]
        ttk::button $r.l.top.${wname} -text $topdir \
            -command "toolbar.invoke_rosette $wname" \
            -image [toolbar.rosette_image ${wname}] \
            -width $rose_width
    }
    ttk::label $r.l.top.sep1 -width $sep_width
    ttk::label $r.l.top.sep2 -width $sep_width
    foreach toppack {northwest north northeast sep1 up sep2 in} {
        pack configure $r.l.top.${toppack} -side left -in $r.l.top }

    ttk::frame $r.l.mid

    foreach middir {West Home East Out Down} {
        set wname [string tolower $middir]
        ttk::button $r.l.mid.${wname} -text $middir \
            -command "toolbar.invoke_rosette $wname" \
            -image [toolbar.rosette_image ${wname}] \
            -width $rose_width
    }

    ttk::label $r.l.mid.sep1 -width $sep_width
    ttk::label $r.l.mid.sep2 -width $sep_width
    foreach midpack {west home east sep1 down sep2 out} {
        pack configure $r.l.mid.${midpack} -side left -in $r.l.mid }

    frame $r.l.bot

    foreach botdir {Southwest South Southeast} {
        set wname [string tolower $botdir]
        ttk::button $r.l.bot.${wname} -text $botdir \
            -command "toolbar.invoke_rosette $wname" \
            -image [toolbar.rosette_image ${wname}] \
            -width $rose_width
    }

    global dig_with_rosette dig_room_name

    set defaultdig [worlds.get_generic Off {} {} DigByDefault]
    if { [string tolower $defaultdig] == "on" } { set dig_with_rosette 1 } else { set dig_with_rosette 0 }

    set dig_room_name ""

    ttk::label $r.l.bot.diglabel -text " Dig: "
    ttk::checkbutton $r.l.bot.dig -variable dig_with_rosette

    foreach botpack {southwest south southeast} {
        pack configure $r.l.bot.${botpack} -side left -in $r.l.bot }

    foreach digging {dig diglabel} {
        pack configure $r.l.bot.${digging} -side right -in $r.l.bot }

    pack configure $r.l.top -side top -in $r.l -fill x
    pack configure $r.l.bot -side bottom -in $r.l -fill x
    pack configure $r.l.mid -in $r.l -fill x

    pack configure $r.l -side left -in $r

    ttk::frame $r.r
    pack configure $r.r -side left -in $r

    if { [string tolower $rosedialog] == "off" } {
        window.add_toolbar $r
        window.repack
    }
	wm resizable $r 0 0
}

proc toolbar.invoke_rosette dir {
    global dig_with_rosette dig_room_name dig_return_exit close_on_completion follow_new_exit
    if { $dig_with_rosette && $dir != "home" } {
        set rn .dig_dialog
        catch { destroy .dig_dialog }
        toplevel $rn
        wm title $rn "Dig $dir to ..."

        ttk::frame $rn.input
        ttk::label $rn.input.textstuff -text "Enter room name or obj#:"
        entry $rn.input.room -width 35 \
            -background [colourdb.get pink] \
            -font [fonts.fixedwidth]
            
        bind $rn.input.room <Return> "toolbar.perform_dig $dir"
        bind $rn.input.room <Escape> "destroy .dig_dialog"
        
        $rn.input.room insert 0 $dig_room_name
        pack configure $rn.input.textstuff -side top -in $rn.input
        pack configure $rn.input.room -side bottom -in $rn.input
        pack configure $rn.input -side top -in $rn -fill x

        set defaultdigreturn [worlds.get_generic On {} {} DigReturnByDefault]
        if { [string tolower $defaultdigreturn] == "on" } { set dig_return_exit 1 } else { set dig_return_exit 0 }

        set defaultcloseoncomp [worlds.get_generic On {} {} DigCloseOnCompletion]
        if { [string tolower $defaultcloseoncomp] == "on" } { set close_on_completion 1 } else { set close_on_completion 0 }

        set defaultfollownew [worlds.get_generic On {} {} DigFollowNewExit]
        if { [string tolower $defaultfollownew] == "on" } { set follow_new_exit 1 } else { set follow_new_exit 0 }

        ttk::frame $rn.options1

        ttk::label $rn.options1.closelabel -text "Close on completion:" -width 20 -justify left -anchor w
        ttk::checkbutton $rn.options1.closeoncomplete -variable close_on_completion
        pack configure $rn.options1.closelabel -side left -in $rn.options1
        pack configure $rn.options1.closeoncomplete -side left -in $rn.options1
        pack configure $rn.options1 -side top -in $rn -fill x

        ttk::frame $rn.options2

        ttk::label $rn.options2.followlabel -text "Follow new exit:" -width 20 -justify left -anchor w
        ttk::checkbutton $rn.options2.follownewexit -variable follow_new_exit
        pack configure $rn.options2.followlabel -side left -in $rn.options2
        pack configure $rn.options2.follownewexit -side left -in $rn.options2
        pack configure $rn.options2 -side top -in $rn -fill x

        ttk::frame $rn.options3

        ttk::label $rn.options3.returnlabel -text "Dig return exit:" -width 20 -justify left -anchor w
        ttk::checkbutton $rn.options3.digreturnexit -variable dig_return_exit
        pack configure $rn.options3.returnlabel -side left -in $rn.options3
        pack configure $rn.options3.digreturnexit -side left -in $rn.options3
        pack configure $rn.options3 -side top -in $rn -fill x

        ttk::frame $rn.buttons
        ttk::button $rn.buttons.ok -text "OK" -command "toolbar.perform_dig $dir"
        ttk::button $rn.buttons.cancel -text "Cancel" -command "destroy .dig_dialog"

        pack configure $rn.buttons.cancel -side right -in $rn.buttons
        pack configure $rn.buttons.ok -side left -in $rn.buttons
        pack configure $rn.buttons -side top -in $rn -fill x
        window.focus $rn.input.room
    } else {
        client.outgoing $dir
    }
}

proc toolbar.perform_dig dir {
    global dig_room_name dig_return_exit close_on_completion follow_new_exit
    set dig_room_name [.dig_dialog.input.room get]
    set dig_cmd [worlds.get_generic {} {} {} RosetteDigCmd]
    if { $close_on_completion } { destroy .dig_dialog }

    if { $dig_return_exit } {
        if { $dir == "north" } { set dig_dir "north,n|south,s" }
        if { $dir == "south" } { set dig_dir "south,s|north,n" }
        if { $dir == "east" } { set dig_dir "east,e|west,w" }
        if { $dir == "west" } { set dig_dir "west,w|east,e" }
        if { $dir == "northwest" } { set dig_dir "northwest,nw|southeast,se" }
        if { $dir == "northeast" } { set dig_dir "northeast,ne|southwest,sw" }
        if { $dir == "southwest" } { set dig_dir "southwest,sw|northeast,ne" }
        if { $dir == "southeast" } { set dig_dir "southeast,se|northwest,nw" }
        if { $dir == "up" } { set dig_dir "up,u|down,d" }
        if { $dir == "down" } { set dig_dir "down,d|up,u" }
        if { $dir == "in" } { set dig_dir "in|out,o" }
        if { $dir == "out" } { set dig_dir "out,o|in" }
    } else {
        if { $dir == "north" } { set dig_dir "north,n" }
        if { $dir == "south" } { set dig_dir "south,s" }
        if { $dir == "east" } { set dig_dir "east,e" }
        if { $dir == "west" } { set dig_dir "west,w" }
        if { $dir == "northwest" } { set dig_dir "northwest,nw" }
        if { $dir == "northeast" } { set dig_dir "northeast,ne" }
        if { $dir == "southwest" } { set dig_dir "southwest,sw" }
        if { $dir == "southeast" } { set dig_dir "southeast,se" }
        if { $dir == "up" } { set dig_dir "up,u" }
        if { $dir == "down" } { set dig_dir "down,d" }
        if { $dir == "in" } { set dig_dir "in" }
        if { $dir == "out" } { set dig_dir "out,o" }
    }

    client.outgoing "$dig_cmd $dig_dir to $dig_room_name"
    if { $follow_new_exit } { client.outgoing $dir }
}

proc toolbar.destroy_rosette {} {
    if { [winfo exists .rosettetb] == 1 } {
        window.remove_toolbar .rosettetb
        destroy .rosettetb
    }
}

proc toolbar.rosette_image rose_dir {
    set use [worlds.get_generic Off {} {} UseGraphicalRose]
    if { [string tolower $use] == "on" } { return "i_$rose_dir" } { return "" }
}

proc toolbar.rosette_toggle {} {
    if { [winfo exists .rosettetb] == 1 } { toolbar.destroy_rosette } { toolbar.create_rosette }
}

proc toolbar.client_toolbar_toggle {} {
    if { [winfo exists .clienttb] == 1 } { toolbar.destroy_client_toolbar } { toolbar.create_client_toolbar }
}

proc toolbar.create_client_toolbar {} {
    if { [winfo exists .clienttb] == 1 } { return }

    set tbstyle [worlds.get_generic {} {} {} ToolBarStyle]

    frame .clienttb -bd 1 -relief sunken -highlightthickness 2

    ttk::button .clienttb.open -image i_open -command "window.open"
    set_balloon .clienttb.open "Open a New Session"
    ttk::button .clienttb.disc -image i_disc -command "window.do_disconnect"
    set_balloon .clienttb.disc "Close Current Session"
    ttk::label .clienttb.sep1 -width 1
    ttk::button .clienttb.worlds -image i_worlds -command "window.open_list"
    set_balloon .clienttb.worlds "Open Worlds Dialog"
    ttk::button .clienttb.pref -image i_pref -command "preferences.edit"
    set_balloon .clienttb.pref "Edit Preferences"
    ttk::button .clienttb.triggers -image i_triggers -command "edittriggers.edit"
    set_balloon .clienttb.triggers "Edit Triggers"
    ttk::label .clienttb.sep2 -width 1
    ttk::button .clienttb.cut -image i_cut -command "ui.delete_selection .input"
    set_balloon .clienttb.cut "Cut"
    ttk::button .clienttb.copy -image i_copy -command "ui.copy_selection .input"
    set_balloon .clienttb.copy "Copy"
    ttk::button .clienttb.paste -image i_paste -command "ui.paste_selection .input"
    set_balloon .clienttb.paste "Paste"
    ttk::button .clienttb.editsel -image i_editsel -command "paste.do_selection"
    set_balloon .clienttb.editsel "Paste Selection"
    ttk::label .clienttb.sep3 -width 1
    ttk::button .clienttb.editor -image i_editor -command "edit.SCedit {} {} {} Editor Editor"
    set_balloon .clienttb.editor "Open Editor"
    ttk::button .clienttb.macmoose -image i_macmoose -command "macmoose.create_browser"
    set_balloon .clienttb.macmoose "Open MacMOOSE Browser"
    ttk::button .clienttb.toolbartog -image i_toolbar -command "toolbar.toolbar_toggle"
    set_balloon .clienttb.toolbartog "Toggle Custom Toolbar"
    ttk::button .clienttb.rosettetog -image i_rosette -command "toolbar.rosette_toggle"
    set_balloon .clienttb.rosettetog "Toggle Rosette"
    ttk::label .clienttb.sep4 -width 1
    ttk::button .clienttb.log -image i_log -command "logging.create_dialog"
    set_balloon .clienttb.log "Logging"
    ttk::button .clienttb.exit -image i_exit -command "client.exit"
    set_balloon .clienttb.exit "Close tkMOO"

    foreach cltbpack {open disc sep1 worlds pref triggers sep2 cut copy paste editsel sep3 editor macmoose toolbartog rosettetog sep4 log exit} {
        pack .clienttb.${cltbpack} -side left }

    window.add_toolbar .clienttb
    window.repack
}

proc toolbar.destroy_client_toolbar {} {
    if { [winfo exists .clienttb] == 1 } {
        window.remove_toolbar .clienttb
        destroy .clienttb
    }
}

proc toolbar.load_editorbar {w args} {
    set use [worlds.get_generic Off {} {} UseEditToolBar]
    if { [string tolower $use] == "on" } { toolbar.create_editorbar $w }
}

proc toolbar.create_editorbar w {
    if { [winfo exists $w.edittb] == 1 } { return }
    edit.add_toolbar $w edittb
    ttk::frame $w.edittb
    edit.repack $w

    ttk::button $w.edittb.open -image i_open -command "edit.fs_open $w"
    set_balloon $w.edittb.open "Open"
    ttk::button $w.edittb.save -image i_save -command "edit.fs_save $w"
    set_balloon $w.edittb.save "Save"
    ttk::button $w.edittb.saveas -image i_saveas -command "edit.fs_save_as $w"
    set_balloon $w.edittb.saveas "Save As"
    ttk::label $w.edittb.sep1 -width 1
    ttk::button $w.edittb.cut -image i_cut -command "edit.do_cut $w"
    set_balloon $w.edittb.cut "Cut"
    ttk::button $w.edittb.copy -image i_copy -command "edit.do_copy $w"
    set_balloon $w.edittb.copy "Copy"
    ttk::button $w.edittb.paste -image i_paste -command "edit.do_paste $w"
    set_balloon $w.edittb.paste "Paste"
    ttk::label $w.edittb.sep2 -width 1
    ttk::button $w.edittb.find -image i_find -command "edit.find $w"
    set_balloon $w.edittb.find "Find"
    ttk::button $w.edittb.goto -image i_goto -command "edit.goto $w"
    set_balloon $w.edittb.goto "Goto"
    ttk::label $w.edittb.sep3 -width 1
    ttk::button $w.edittb.exit -image i_exit -command "edit.destroy $w"
    set_balloon $w.edittb.exit "Close Editor"

    foreach item {open save saveas sep1 cut copy paste sep2 find goto sep3 exit} {
        pack configure $w.edittb.$item -side left -in $w.edittb -fill x }
}

proc toolbar.destroy_editorbar w {
    if { [winfo exists $w.edittb] == 1 } {
        edit.remove_toolbar $w edittb
        destroy $w.edittb
    }
}

proc toolbar.toggle_editorbar w {
    if { [winfo exists $w.edittb] == 1 } { toolbar.destroy_editorbar $w } { toolbar.create_editorbar $w }
}
