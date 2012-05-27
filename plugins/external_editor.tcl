package require fileutil

set replace 0

client.register external_editor start

global external_editor
global external_editor_db
set external_editor "C:\\Program Files (x86)\\Vim\\vim72\\gvim.exe"

proc external_editor.start {} {
    edit.register load external_editor.do_load 70
}

proc external_editor.do_load { w args } {
    # external_editor.SCedit "pre" "lines" "post" "title" "icon"
}
 

proc external_editor.create { title icon_title } {
    set filename [::fileutil::tempfile "tkmoo-"]
    return $filename
}

proc external_editor.destroy { editor } { }

proc external_editor.set_type { editor type } {
    window.displayCR "set_type"
}

proc external_editor.SCedit { pre lines post title icon_title filename } {
    global external_editor
    global external_editor_db

    if { $pre == "" } {
        if { $post == "" } {
            set data $lines
        } {
            set data [concat $lines [list $post]]
        }
    } {
        if { $post == "" } {
            set data [concat [list $pre] $lines]
        } {
            set data [concat [list $pre] $lines [list $post]]
        }
    }

    set fh [open $filename r+]
    foreach line $data { puts $fh "$line" }
    close $fh

    set editorpid [ exec $external_editor $filename & ]

    # mmkay let's start watching that file.
    set external_editor_db($filename:editorpid) $editorpid
    set external_editor_db($filename:mtime) [ file mtime $filename ]
    external_editor._check_file $filename
}

proc external_editor._check_file { filename } {
    global external_editor_db
    if { [file mtime $filename] != $external_editor_db($filename:mtime) } {
        window.displayCR "file $filename changed!";
    }
    # stat the file
window.displayCR "just before"
    after 250 {
        window.displayCR "going in...."
        external_editor._check_file $filename
        window.displayCR "coming out...."
    }
}

if $replace {
    # replace the existing edit subs.
    rename edit.SCedit edit.SCedit.old
    rename external_editor.SCedit edit.SCedit

    rename edit.create edit.create.old
    rename external_editor.create edit.create

    rename edit.destroy edit.destroy.old
    rename external_editor.destroy edit.destroy

    rename edit.set_type edit.set_type.old
    rename external_editor.set_type edit.set_type

}
