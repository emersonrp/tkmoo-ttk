#
    #       tkMOO
    #       ~/.tkMOO-lite/plugins/xmcp_example.tcl
    #
    #       some examples of using XMCP/1.1
    
    # Example 1.  a simple one-line message it just passes parameters.
    # Extract the values of each parameter and print them out on the main
    # window.
    #
    # make a procedure called 'xmcp11.do_'
    proc xmcp11.do_xmcp-example-one {} {
    
        # it's possible to spoof the opening $#$ in MOO so we check the
        # authentication key, since only a trusted task can extract the key
        # from the driver when it builds the XMCP message.
        if { [xmcp11.authenticated silent] == 0 } {
            window.displayCR "*** Unauthenticated message xmcp-example-one"
            return
        }
    
        # get a token from the client which identifies this message
        set which [request.current]
    
        set param1 [request.get $which param1]
        set param2 [request.get $which param2]
    
        window.displayCR "Processing xmcp-example-one"
        window.displayCR "  param1=$param1"
        window.displayCR "  param2=$param2"
    }
    
    # make a procedure called 'xmcp11.do_*', the '*' denotes
    # a multiline message
    proc xmcp11.do_xmcp-example-two* {} {
        if { [xmcp11.authenticated silent] == 0 } {
            window.displayCR "*** Unauthenticated message xmcp-example-two"
            return
        }
    
        # Set a special variable, the name of the procedure to be called
        # when all the lines of data have been read in.  this procedure is
        # called when the END message for this upload arrives.
    
        # we can call this anything we want, but for sake of documentation
        # I've called it 'xmcp-example-two*'.  When it gets called the client
        # will call 'xmcp11.do_callback_xmcp-example-two*'
        request.set current xmcp11_multiline_procedure "xmcp-example-two*"
    }
    
    # make a callback procedure with the same name as the value you put in
    # the 'xmcp11_multiline_procedure' line above.
    proc xmcp11.do_callback_xmcp-example-two* {} {
        set which [request.current]
        set param1 [request.get $which param1]
        set param2 [request.get $which param2]
    
        # the data lines are held in a special variable '_lines'
        set lines [request.get $which _lines]
        window.displayCR "Processing xmcp-example-two"
        window.displayCR "  param1=$param1"
        window.displayCR "  param2=$param2"
        window.displayCR "  lines:"
        foreach line $lines {
            window.displayCR "    $line"
        }
        window.displayCR "  ---"
    }
    
    # Just be sure the TCL actually compiled!
    # window.displayCR "Loaded Plugin xmcp_example.tcl"

