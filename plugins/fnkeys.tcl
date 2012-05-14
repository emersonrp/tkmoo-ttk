#
#       tkMOO
#       ~/.tkMOO-lite/plugins/fnkeys.tcl
#

# tkMOO-light is Copyright (c) Andrew Wilson 1994,1995,1996,1997,1998,1999
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

# Manage function key bindings to commands.  Press on a key and
# send the designated script to the server.

client.register fnkeys start 60

proc fnkeys.start {} {

    preferences.register client {Function Keys} {
        { {directive FNKeyF1Macro}
            {type text}
            {default {}}
            {default_if_empty}
            {display "Key F1"} }
        { {directive FNKeyF2Macro}
            {type text}
            {default {}}
            {default_if_empty}
            {display "Key F2"} }
        { {directive FNKeyF3Macro}
            {type text}
            {default {}}
            {default_if_empty}
            {display "Key F3"} }
        { {directive FNKeyF4Macro}
            {type text}
            {default {}}
            {default_if_empty}
            {display "Key F4"} }
        { {directive FNKeyF5Macro}
            {type text}
            {default {}}
            {default_if_empty}
            {display "Key F5"} }
        { {directive FNKeyF6Macro}
            {type text}
            {default {}}
            {default_if_empty}
            {display "Key F6"} }
        { {directive FNKeyF7Macro}
            {type text}
            {default {}}
            {default_if_empty}
            {display "Key F7"} }
        { {directive FNKeyF8Macro}
            {type text}
            {default {}}
            {default_if_empty}
            {display "Key F8"} }
    }

    foreach key {F1 F2 F3 F4 F5 F6 F7 F8} {
        bind . <$key> "+fnkeys.invoke $key"
    }
}

proc fnkeys.invoke key {
    set action [worlds.get_generic {} {} {} FNKey${key}Macro]
    regsub "\n\$" $action {} action
    if { $action != {} } { client.outgoing "$action" }
}
