#
#

proc db.set { id field val args } {
    global db
    if { $args == {} } {
        set db($id:$field) $val
    } {
        eval db.set $db($id:$field) [concat [list $val] $args]
    }
}

proc db.unset { id field val args } {
    global db
    if { $args == {} } {
        unset -nocomplain db($id:$field) $val
    } {
        eval db.unset $db($id:$field) [concat [list $val] $args]
    }
}

proc db.get { id field args } {
    global db
    if { $args == {} } {
        return $db($id:$field)
    } {
        return [eval db.get $db($id:$field) $args]
    }
}

proc db.drop object {
    global db
    foreach name [array names db "$object:*"] {
        unset db($name)
    }
}

proc db.exists { id field args } {
    global db
    if { $args == {} } {
        return [info exists db($id:$field)]
    } {
        return [eval db.exists $db($id:$field) $args]
    }
}
