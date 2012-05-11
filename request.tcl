

proc request.get { tag key } {
    global request_data
    return $request_data($tag.$key)
}

proc request.set { tag key value } {
    global request_data
    set request_data($tag.$key) $value
}

proc request.create tag {
    global request_data
    set request_data($tag.lines) ""
}

proc request.destroy tag {
    global request_data
    foreach name [array names request_data "$tag.*"] {
        unset request_data($name)
    }
}

proc request.duplicate { source target } {
    global request_data
    foreach key [array names request_data "$source.*"] {
    regsub "^$source\." $key {} key
        set request_data($target.$key) $request_data($source.$key)
    }
}

proc request.current {} {
    set which current
    catch { set which [request.get current tag] }
    return $which
}
