client.register fp start
package require base64

proc fp.start {} {
window.menu_tools_add "file transfer" "io.outgoing @fp-request"
}

proc encode file {
	set fp [open $file r]
	fconfigure $fp -translation binary
	set data [read $file]
	close $fp
	set encode [::base64::encode $data]
	return $encode
}

proc fileopen {} {
    set filetypes { 
	{{All Files} {*} TEXT}
	{{Text Files} {.txt} TEXT}
	{{Binary Files} {.exe} }
    }
    set display "Select file to transfer"
    set filename [tk_getOpenFile -filetypes $filetypes \
                                 -title "$display"]

    if { $filename == "" } {
	return;
    }
    return $filename
}

proc send.request {} {
io.outgoing "@fp-request"
}

proc ask.request player {
set request [tk_dialog .ftr "File Transfer Request from $player" "$player has requested a file transfer do you want to accept?" "" 0 yes no]
if {$request == 0} {
io.outgoing "@fp-accept $player"
} else {
io.outgoing "@fp-reject $player"
}
}

proc fp.accepted {player id} {
 set myFile [tk_getOpenFile]

 # ---- open and read file ----
 set  myFP  [ open  $myFile  r ]
 fconfigure $myFP -translation binary
 set  {pure file}  [ read  $myFP ]
 close  $myFP

 # ---- encode ----
 set  {encoded file}  [ ::base64::encode ${pure file} ]

 # puts  ${encoded file}
 # output looks good
 set filename [lindex [file split $myFile] end]
 io.outgoing "@fp-send $id $filename"
 io.outgoing "${encoded file}"
 io.outgoing "."
}

proc fp.recieving {player id filename code} {
set data [::base64::decode $code]
set location [file join [pwd] mrf $player]
file mkdir $location
set file [file join $location $filename]
set x [catch {set fid [open $file w]}]
 fconfigure $fid -translation binary
   set y [catch {puts $fid $data}]
   set z [catch {close $fid}]
   if { $x || $y || $z || ![file exists $file] || ![file isfile $file] || ![file readable $file] } {
   tk_messageBox -parent . -icon error \
                 -message "An error occurred while saving to \"$file\""
      } else {
   tk_messageBox -parent . -icon info \
                 -message "Save successful\nfile location: $file"
	io.outgoing "@fp-completed $id"
      }
}

proc xmcp11.do_fp-ask {} {
    
        if { [xmcp11.authenticated silent] == 0 } {
            window.displayCR "*** Unauthenticated message fp-ask"
            return
        }
    
        set which [request.current]
    
        set player [request.get $which player]
        
	ask.request $player
    }
    
proc xmcp11.do_fp-confirm {} {
    
        if { [xmcp11.authenticated silent] == 0 } {
            window.displayCR "*** Unauthenticated message fp-confirm"
            return
        }
    
        set which [request.current]
    
	set player [request.get $which player]
	set responce [request.get $which responce]
        set id [request.get $which id]
	
	if {$responce == "yes"} {
	fp.accepted $player $id
} else {
	window.displayCR "$player has refused your request for the file transfer"
	return
}
    }

proc xmcp11.do_fp-accepted {} {
    
        if { [xmcp11.authenticated silent] == 0 } {
            window.displayCR "*** Unauthenticated message fp-accepted"
            return
        }
    
        set which [request.current]
    
        set player [request.get $which player]
        set id [request.get $which id]
	
	fp.accepted $player $id
    }

proc xmcp11.do_callback_fp-recieving* {} {
	set which [request.current]
        set player [request.get $which player]
	set id [request.get $which id]
	set filename [request.get $which filename]
	set lines [request.get $which _lines]
	fp.recieving $player $id $filename $lines
    }
proc xmcp11.do_fp-recieving* {} {
        if { [xmcp11.authenticated silent] == 0 } {
            window.displayCR "*** Unauthenticated message fp-recieving"
            return
        }
        request.set current xmcp11_multiline_procedure "fp-recieving*"
    }
proc xmcp11.do_fp-completed {} {
    
        if { [xmcp11.authenticated silent] == 0 } {
            window.displayCR "*** Unauthenticated message fp-completed"
            return
        }
        set which [request.current]
    
        set player [request.get $which player]
        client.display "Transfer completed with $player"
}
proc xmcp11.dp_fp-failed {} {
 if { [xmcp11.authenticated silent] == 0 } {
            window.displayCR "*** Unauthenticated message fp-failed"
            return
        }
	set which [request.current]
    
        set player [request.get $which player]
	tk_dialog "transfer failed with $player" "$player has cancelled the transfer"
}