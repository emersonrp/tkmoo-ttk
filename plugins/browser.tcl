    proc xmcp11.do_browse* {} {
        if { [xmcp11.authenticated] == 1 } {
            request.set current xmcp11_multiline_procedure "browse*"
        }
    }

    proc xmcp11.do_callback_browse* {} {
        set which [request.current]
        set browser   [request.get $which browser]
        set this_name   [request.get $which this_name]
        set this_obj    [request.get $which this_obj]
        set parent_name [request.get $which parent_name]
        set parent_obj  [request.get $which parent_obj]
        set children    [request.get $which _lines]
        browser.SCbrowse $browser $this_name $this_obj $parent_name $parent_obj $children
    }

    proc browser.SCbrowse { browser this_name this_obj parent_name \
        parent_obj children } {

        browser.set $this_obj ok 1
        browser.set $this_obj name $this_name
        browser.set $this_obj parent $parent_obj
        browser.set $parent_obj name $parent_name
        browser.set $this_obj children $children

        if { $browser == "new" } {
            set browser [browser.create]
        }

        wm title $browser "Object Browser: $this_name ($this_obj)"
        wm iconname $browser "Object Browser"

        $browser.text configure -state normal
        $browser.text delete 1.0 end

        $browser.text insert insert "PARENT: $parent_name ("
            browser.link $browser $parent_obj
        $browser.text insert insert ")\n"
        $browser.text insert insert "  NAME: $this_name ($this_obj)\n"

        browser.recurse $browser $children 0

        $browser.text configure -state disabled
    }
    proc browser.SCbrowse { browser this_name this_obj parent_name \
        parent_obj children } {

        browser.set $this_obj ok 1
        browser.set $this_obj name $this_name
        browser.set $this_obj parent $parent_obj
        browser.set $parent_obj name $parent_name
        browser.set $this_obj children $children

        if { $browser == "new" } {
            set browser [browser.create]
        }

        wm title $browser "Object Browser: $this_name ($this_obj)"
        wm iconname $browser "Object Browser"

        $browser.text configure -state normal
        $browser.text delete 1.0 end

        $browser.text insert insert "PARENT: $parent_name ("
            browser.link $browser $parent_obj
        $browser.text insert insert ")\n"
        $browser.text insert insert "  NAME: $this_name ($this_obj)\n"

        browser.recurse $browser $children 0

        $browser.text configure -state disabled
    }


