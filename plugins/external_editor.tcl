client.register external_editor start

proc external_editor.start {} {
	edit.register load external_editor.do_load 70
}

proc external_editor.do_load { w args } {
    window.menu_tools_add "External Editor" {external_editor.SCedit {} {} {} "Editor" "Editor"}
}
 
global editor
set editor "C:\\Program Files (x86)\\Vim\\vim72\\gvim.exe"


proc external_editor.SCedit { pre lines post title icon_title {e ""}} {
	global editor
	exec $editor &
}
