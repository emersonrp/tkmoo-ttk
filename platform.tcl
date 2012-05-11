# set up the platform convenience thingie

proc platform.is_windows {} {
  global tcl_platform
  if { $tcl_platform(platform) == "windows" } { return 1 }
  return 0
}

proc platform.is_osx {} {
  global tcl_platform
  if { $tcl_platform(platform) == "unix" &&
      [string tolower $tcl_platform(os)] == "darwin" } { return 1 }
  return 0
}

proc platform.is_linux {} {
  global tcl_platform
  if { $tcl_platform(platform) == "unix" &&
      [string tolower $tcl_platform(os)] != "darwin" } { return 1 }
  return 0
}
