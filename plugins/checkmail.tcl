#
#    tkMOO
#    ~/.tkMOO-lite/plugins/checkmail.tcl
#
#    Keep an eye on the status of received mail

# tkMOO-light is Copyright (c) Andrew Wilson 1994,1995,1996,1997,1998
#
#    All Rights Reserved
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

client.register checkmail start
client.register checkmail client_connected
client.register checkmail client_disconnected

proc checkmail.start {} {
    global checkmail_frame
    set checkmail_frame 0
}

preferences.register checkmail {Statusbar Settings} {
    { {directive UseCheckmail}
        {type boolean}
        {default Off}
        {display "Check mail"} }
    { {directive CheckMailMailbox}
        {type string}
        {default ""}
        {default_if_empty}
        {display "Mailbox"} }
}

proc checkmail.client_connected {} {

    set use [worlds.get_generic Off {} {} UseCheckmail]

    if { [string tolower $use] == "on" } {
        checkmail.create
    } {
        # get rid of it if we were using it before now
        checkmail.destroy
    }
    checkmail.init
    checkmail.stat
    return [modules.module_deferred]
}

proc checkmail.client_disconnected {} {
    return [modules.module_deferred]
}

proc checkmail.destroy {} {
    global checkmail_frame
    catch { window.delete_statusbar_item $checkmail_frame }
}

proc checkmail.create {} {
    global checkmail_task checkmail_frame checkmail_mtime

    # initialise the state.  means we get a meaningful initial message
    checkmail.init

    set f $checkmail_frame

    if { [winfo exists $f] == 0 } {
        set checkmail_frame [window.create_statusbar_item]
        set f $checkmail_frame
        frame $f -bd 0
        label $f.l -text "" -bd 1 -relief raised -bg lightgreen
        pack $f.l -side left
        pack $f -side right
        window.repack
    }

    set checkmail_task [util.unique_id "checkmail"]
    checkmail.check $checkmail_task
}

proc checkmail.check task_id {
    global checkmail_task checkmail_frame
    set f $checkmail_frame
    if { [winfo exists $f] == 0 } { return };
    if { $task_id != $checkmail_task } {
        # kill this task...
        return
    }
    set stat [checkmail.stat]
    set messages {
        "No mailbox configured"
        "You have mail"
        "You have new mail"
        "No mail"
    }
    if { $stat != -1 } {
        $f.l configure -text [lindex $messages $stat]
    }
    after 5000 checkmail.check $task_id
}

proc checkmail.init {} {
    global checkmail_mtime
    # [re]initialise the widget
    catch { unset checkmail_mtime }
}

proc checkmail.stat {} {
    global checkmail_mtime checkmail_size
    set mailbox ""
    catch {
        set mailbox [worlds.get [worlds.get_current] CheckMailMailbox]
    }
    # is a file name specified, does the file exists, is it readable
    if { $mailbox == "" } {
        # ignore
        return 0
    };

    # stat the file
    set mtime [file mtime $mailbox]
    # is there more information than before?
    set size [file size $mailbox]

    if { [info exists checkmail_mtime] == 0 } {
        set checkmail_mtime $mtime
        set checkmail_size $size
        if { $size == 0 } {
            # no mail
            return 3
        } {
            # you have mail
            return 1
        }
    }

    if { ($mtime > $checkmail_mtime) &&
         ($size > $checkmail_size) } {
        set checkmail_mtime $mtime
        set checkmail_size $size
        # you have new mail
        return 2
    }

    if { ($mtime == $checkmail_mtime) && ($size == $checkmail_size) } {
        # no change
        return -1
    }

    if { $size == 0 } {
        set checkmail_mtime $mtime
        set checkmail_size $size
        # no mail
        return 3
    } {
        set checkmail_mtime $mtime
        set checkmail_size $size
        # you have mail
        return 1
    }
}
