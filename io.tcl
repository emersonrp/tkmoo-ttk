proc io.start {} {
    global io_output
    set io_output ""
}

proc io.outgoing line {
    set session ""
    catch {
        set session [db.get current session]
    }
    if { $session == "" } { return }
    set conn [db.get $session connection]
    if { $conn != "" } {
        puts $conn "$line"
        flush $conn
    }
}

proc io.receive_session-line session {
    set conn [db.get $session connection]

    if { $conn == "" } return


    set nchar -2
    catch {set nchar [gets $conn line]}

    if { $nchar == -2 } {
        window.displayCR  "Connection timed out" window_highlight
        io.has_closed_session $session
        return
    }

    if { $nchar == -1 } {
        if { [eof $conn] } {
            io.has_closed_session $session
            return
        }
        if { [fblocked $conn] } { return }
        puts "io.receive-line: some error (I don't understand this fully)"
    }

    set event [util.unique_id event]
    db.set $event line $line
    db.set $event session $session
    client.incoming $event
}

proc io.receive-line {} {
    global io_output

    if { $io_output == "" } return


    set nchar -2
    catch {set nchar [gets $io_output line]}

    if { $nchar == -2 } {
        window.displayCR  "Connection timed out" window_highlight
        io.has_closed
        return
    }

    if { $nchar == -1 } {
        if { [eof $io_output] } {
            io.has_closed
            return
        }
        if { [fblocked $io_output] } {
            return
        }
        puts "io.receive-line: some error (I don't understand this fully)"
    }

    set event [util.unique_id event]
    db.set $event line $line
    client.incoming $event
}

set io_buffer ""

proc io.data_available_conn conn { return [fblocked $conn] }

proc io.data_available {} {
    global io_output
    return [fblocked $io_output]
}

proc io.noCR {} {
    global io_noCR
    return $io_noCR
}

proc io.ensure_linemode { line } {
    global io_buffer io_buffer_returns
    if { [client.mode] == "line" } { return 0 }
    if { [io.noCR] == 1 } {
        set io_buffer_returns $line
        puts "io.ensure_linemode => 1"
        return 1
    }
    return 0
}

set io_noCR 0
proc io.read_buffer_session session {
    global io_output io_buffer io_noCR

    set buffer [db.get $session buffer]

    if { $buffer == "" } { return [list 0] }

    set conn [db.get $session connection]

    set first [string first "\n" $buffer]
    set io_noCR 0

    if { $first == -1 } {
    if { [io.data_available_conn $conn] == 1 } {
        set io_noCR 1

        set data $buffer
        db.set $session buffer ""
    } {
        return [list 0]
    }
    } {
        set data [string range $buffer 0 [expr $first - 1]]
        db.set $session buffer [string range $buffer [expr $first + 1] end]
    }
    return [list 1 $data]
}

set io_noCR 0
proc io.read_buffer {} {
    global io_output io_buffer io_noCR
    if { $io_buffer == "" } { return [list 0] }
    set first [string first "\n" $io_buffer]
    set io_noCR 0
    if { $first == -1 } {
        if { [io.data_available] == 1 } {
            set io_noCR 1

            set data $io_buffer
            set io_buffer ""
        } {
            return [list 0]
        }
    } {
        set data [string range $io_buffer 0 [expr $first - 1]]
        set io_buffer [string range $io_buffer [expr $first + 1] end]
    }
    return [list 1 $data]
}

proc io.receive_session-character session {
    global io_output io_buffer io_buffer_returns

    set conn [db.get $session connection]

    set data_size 100

    if { $conn == "" } { return }

    set buffer ""
    catch { set buffer [db.get $session buffer] }

    set data [read $conn $data_size]
    set buffer "$buffer$data"
    db.set $session buffer $buffer

    if { [eof $conn] == 1 } {
        io.has_closed
        return
    }


    set io_buffer_returns ""
    set data [io.read_buffer_session $session]
    while { [lindex $data 0] } {
        set line [lindex $data 1]

        set event [util.unique_id event]
        db.set $event line $line

        client.incoming $event
        set data [io.read_buffer_session $session]
    }
}

proc io.receive-character {} {
    global io_output io_buffer io_buffer_returns

    set data_size 100

    if { $io_output == "" } { return }

    set data [read $io_output $data_size]
    set io_buffer "$io_buffer$data"

    if { [eof $io_output] == 1 } {
        io.has_closed
        return
    }


    set io_buffer_returns ""
    set data [io.read_buffer]
    while { [lindex $data 0] } {
        set line [lindex $data 1]

        set event [util.unique_id event]
        db.set $event line $line

        client.incoming $event
        set data [io.read_buffer]
    }
}

proc io.receive_session session {
    io.receive_session-[client.mode] $session
}

proc io.receive {} { io.receive-[client.mode] }

proc io.stop_session session {
    if { $session == "" } { return }
    set conn [db.get $session connection]
    if { $conn == "" } { return }
    close $conn
    db.set $session connection ""
    client.client_disconnected_session $session
}

proc io.stop {} {
    global io_output
    if { $io_output == "" } { return; }
    close $io_output
    set io_output ""
    client.client_disconnected
}

proc io.has_closed_session session {
    global io_output
    set conn [db.get $session connection]

    if { $conn != "" } {
        fileevent $conn readable ""
        set io_output ""
        db.set $session connection ""
        client.client_disconnected_session $session
    };
}

proc io.has_closed {} {
    global io_output

    if { $io_output != "" } {
        fileevent $io_output readable ""
        set io_output ""
        client.client_disconnected
    }
}

proc io.connect_session session {
    set host [db.get $session host]
    set port [db.get $session port]
    set conn ""
    catch { set conn [socket $host $port] }
    db.set $session connection $conn
    if { $conn != "" } {
        set current_session ""
        catch { set current_session [db.get current session] }
        if { $current_session != "" } {

            set this_world ""
            catch { set this_world [db.get $current_session world] }
            worlds.set_current $this_world

            client.disconnect_session $current_session

            set next_world ""
            catch { set next_world [db.get $session world] }
            worlds.set_current $next_world

        }
        io.set_connection $conn
            fconfigure $conn -blocking 0
            fileevent $conn readable "io.receive_session $session"

        client.client_connected_session $session
        return 0
    } {
        io.host_unreachable $host $port
        return 1
    }
}

proc io.connect { host port } {
    set conn ""
    catch { set conn [socket $host $port] }
    if { $conn != "" } {

        set current_world [worlds.get_current]
        io.disconnect
        worlds.set_current $current_world

        io.set_connection $conn
        fconfigure $conn -blocking 0
        fileevent $conn readable {io.receive}
        client.client_connected
        return 0
    } {
        io.host_unreachable $host $port
        return 1
    }
}

proc io.disconnect_session session { io.stop_session $session }

proc io.disconnect {} { io.stop }

proc io.set_connection {{conn ""}} {
    global io_output
    set io_output $conn
}

proc io.host_unreachable { host port } {
    client.host_unreachable $host $port
}
