#
#    tkMOO
#    ~/.tkMOO-lite/plugins/pushurl.tcl
#


client.register pushurl start 60

proc pushurl.start {} {
    mcp21.register dns-com-tkmoo-se-runurl 1.0 \
        dns-com-tkmoo-se-runurl pushurl.dorunurl
}

proc pushurl.dorunurl {} {
    webbrowser.open "http://www.moocode.com"
}
