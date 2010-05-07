client.register media start 60
client.register media client_disconnected
package require Img
package require http
package require snack
package require snackogg

proc media.start {} {
	mcp21.register dns-com-vmoo-mmedia 2.0 \
	    dns-com-vmoo-mmedia-show media.dns-com-vmoo-mmedia-show
      mcp21.register dns-com-vmoo-mmedia 2.0 \
          dns-com-vmoo-mmedia-play media.dns-com-vmoo-mmedia-play
        mcp21.register_internal media mcp_negotiate_end
    }

proc media.mcp_negotiate_end {} {
# ask for serverinfo
    set overlap [mcp21.report_overlap]
    set version [util.assoc $overlap dns-com-vmoo-mmedia]
    if { ($version != {}) && ([lindex $version 1] == 2.0) } {
        mcp21.server_notify dns-com-vmoo-mmedia-accept  [list [list conspeed 0] [list protocols "alias,http,local methods: music,play,preload,show"] [list insert ""] [list music: "Wav,aif,aifc,aiff,asf,asx,au,m1v,m3u,mp2,mp2v,mp3,mpa,mpe,mpeg,mpg,mpv2,snd,wax,wm,wma,wmv,wmx,wvx,wpl,Mid,rmi"] [list play "Wav,aif,aifc,aiff,asf,asx,au,m1v,m3u,mp2,mp2v,mp3,mpa,mpe,mpeg,mpg,mpv2,snd,wax,wm,wma,wmv,wmx,wvx,wpl,Mid,rmi,ogg"] [list show "avi,aif,aifc,aiff,asf,asx,au,m1v,m3u,mp2,mp2v,mp3,mpa,mpe,mpeg,mpg,mpv2,snd,wax,wm,wma,wmv,wmx,wvx,wpl,gif,jpg,png,bmp,ogg"]]
    }
}

proc media.dns-com-vmoo-mmedia-show {} {
# use the correct request_id
set which current
catch { set which [request.get current _data-tag] }
set img [request.get $which file]
set imgr [imageresize $img]
set win .image
toplevel $win
set filename [lindex [file split $img] end]
set name [file rootname $filename]
wm iconname $win "$name - image"
wm title $win "$name - image"
label $win.img -image $imgr
pack $win.img
}

proc imageresize filename {
set url [::http::geturl $filename]
set data [::http::data [::http::geturl $filename]]
::http::cleanup $url
set img [image create photo]
$img put $data
resize $img 200 200 $img
}

proc resize {src newx newy {dest ""} } {

     set mx [image width $src]
     set my [image height $src]
     set temp 0
     if { "$dest" == ""} {
         set dest [image create photo]
     } elseif {"$dest" == $src} {
      set dest [image create photo]
      set temp 1
     }
     $dest configure -width $newx -height $newy

     # Check if we can just zoom using -zoom option on copy
     if { $newx % $mx == 0 && $newy % $my == 0} {

         set ix [expr {$newx / $mx}]
         set iy [expr {$newy / $my}]
         $dest copy $src -zoom $ix $iy
         return $dest
     }

     set ny 0
     set ytot $my

     for {set y 0} {$y < $my} {incr y} {

         #
         # Do horizontal resize
         #

         foreach {pr pg pb} [$src get 0 $y] {break}

         set row [list]
         set thisrow [list]

         set nx 0
         set xtot $mx

         for {set x 1} {$x < $mx} {incr x} {

             # Add whole pixels as necessary
             while { $xtot <= $newx } {
                 lappend row [format "#%02x%02x%02x" $pr $pg $pb]
                 lappend thisrow $pr $pg $pb
                 incr xtot $mx
                 incr nx
             }

             # Now add mixed pixels

             foreach {r g b} [$src get $x $y] {break}

             # Calculate ratios to use

             set xtot [expr {$xtot - $newx}]
             set rn $xtot
             set rp [expr {$mx - $xtot}]

             # This section covers shrinking an image where
             # more than 1 source pixel may be required to
             # define the destination pixel

             set xr 0
             set xg 0
             set xb 0

             while { $xtot > $newx } {
                 incr xr $r
                 incr xg $g
                 incr xb $b

                 set xtot [expr {$xtot - $newx}]
                 incr x
                 foreach {r g b} [$src get $x $y] {break}
             }

             # Work out the new pixel colours

             set tr [expr {int( ($rn*$r + $xr + $rp*$pr) / $mx)}]
             set tg [expr {int( ($rn*$g + $xg + $rp*$pg) / $mx)}]
             set tb [expr {int( ($rn*$b + $xb + $rp*$pb) / $mx)}]

             if {$tr > 255} {set tr 255}
             if {$tg > 255} {set tg 255}
             if {$tb > 255} {set tb 255}

             # Output the pixel

             lappend row [format "#%02x%02x%02x" $tr $tg $tb]
             lappend thisrow $tr $tg $tb
             incr xtot $mx
             incr nx

             set pr $r
             set pg $g
             set pb $b
         }

         # Finish off pixels on this row
         while { $nx < $newx } {
             lappend row [format "#%02x%02x%02x" $r $g $b]
             lappend thisrow $r $g $b
             incr nx
         }

         #
         # Do vertical resize
         #

         if {[info exists prevrow]} {

             set nrow [list]

             # Add whole lines as necessary
             while { $ytot <= $newy } {

                 $dest put -to 0 $ny [list $prow]

                 incr ytot $my
                 incr ny
             }

             # Now add mixed line
             # Calculate ratios to use

             set ytot [expr {$ytot - $newy}]
             set rn $ytot
             set rp [expr {$my - $rn}]

             # This section covers shrinking an image
             # where a single pixel is made from more than
             # 2 others.  Actually we cheat and just remove
             # a line of pixels which is not as good as it should be

             while { $ytot > $newy } {

                 set ytot [expr {$ytot - $newy}]
                 incr y
                 continue
             }

             # Calculate new row

             foreach {pr pg pb} $prevrow {r g b} $thisrow {

                 set tr [expr {int( ($rn*$r + $rp*$pr) / $my)}]
                 set tg [expr {int( ($rn*$g + $rp*$pg) / $my)}]
                 set tb [expr {int( ($rn*$b + $rp*$pb) / $my)}]

                 lappend nrow [format "#%02x%02x%02x" $tr $tg $tb]
             }

             $dest put -to 0 $ny [list $nrow]

             incr ytot $my
             incr ny
         }

         set prevrow $thisrow
         set prow $row

         update idletasks
     }

     # Finish off last rows
     while { $ny < $newy } {
         $dest put -to 0 $ny [list $row]
         incr ny
     }
     update idletasks

     if {$temp == 0} {
     return $dest
     } else {
     $src blank
     $src copy $dest
     $src configure -width $newx -height $newy
     return $src
     image delete $dest
     }
 }

proc media.client_disconnected {} {
catch {destroy .image}
}

proc media.dns-com-vmoo-mmedia-play {} {
set which current
catch { set which [request.get current _data-tag] }
set url [request.get $which file]
set name [file tail $url]
window.set_status "Now Playing: $name" 
play $url
}


proc playstream { socket token } {
     puts "recieved"
     fileevent $socket readable ""
     flush stdout
     list http::cleanup $token
     ::snack::sound s -channel $socket
     for {set i 0} {$i < 30} {incr i} {
         after 100
         flush stdout
     }
     flush stdout
     s play -blocking 0
     return 0
 }

proc play {url} {
::http::geturl $url -handler playstream
}
