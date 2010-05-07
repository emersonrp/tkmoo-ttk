    #   
    #       popup.tcl
    #   

    client.register popup start

    proc popup.start {} {
        edittriggers.register_alias dialog popup.dialog
    }

     proc popup.dialog { {message ""} } {
        set popup .[util.unique_id popup]
        toplevel $popup
        label $popup.l -text $message -font {helvetica 10} -bd 1 -relief raised
        button $popup.b -text Ok -command "destroy $popup"
        pack $popup.l -side top -fill x
        pack $popup.b -side bottom
    }