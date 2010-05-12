client.register social start

proc social.start {} {
	window.menu_tools_add "xsocials" social.social_toggle
}

set social_db(current) 0

proc social.social_toggle {} { 
	if {[winfo exists .buttons] == 1 } {
		social.destroy
	} elseif {[winfo exists .button] == 1 } {
		social.destroy
	} { social.create }
}

proc social.destroy {} {
	if { [winfo exists .button] == 1 } {
		destroy .button
	}
	if { [winfo exists .buttons] == 1 } {
		destroy .buttons
	}
}

proc social.create {} {
	set button .buttons
	toplevel $button
	wm title $button "buttons"
	ttk::frame $button.1
	ttk::frame $button.2
	ttk::frame $button.e
	ttk::frame $button.1.a
	ttk::frame $button.1.b
	ttk::frame $button.1.c
	ttk::frame $button.1.d
	ttk::frame $button.1.e
	ttk::frame $button.1.f
	ttk::frame $button.2.g
	ttk::frame $button.2.h
	ttk::frame $button.2.i
	ttk::frame $button.2.j
	ttk::frame $button.2.k
	ttk::frame $button.2.l
	set button2 .button
	toplevel $button2
	wm title $button2 buttons2
	ttk::frame $button2.1
	ttk::frame $button2.2
	ttk::frame $button2.1.a
	ttk::frame $button2.1.b
	ttk::frame $button2.1.c
	ttk::frame $button2.1.d
	ttk::frame $button2.1.e
	ttk::frame $button2.1.f
	ttk::frame $button2.2.g
	ttk::frame $button2.2.h
	ttk::frame $button2.2.i
	ttk::frame $button2.2.j
	ttk::frame $button2.2.k
	ttk::frame $button2.2.l
	ttk::entry $button.e.e -textvar _user
	ttk::button $button.1.d.xthink -text "xthink" -command { io.outgoing "xthink $_user"}
	ttk::button $button.1.e.xsmile -text "xsmile" -command { io.outgoing "xsmile $_user"}
	ttk::button $button.1.f.xcomfort -text "xcomfort" -command { io.outgoing "xcomfort $_user"}
	ttk::button $button.2.g.xwink -text "xwink" -command { io.outgoing "xwink $_user"}
	ttk::button $button.2.h.xyawn -text "xyawn" -command { io.outgoing "xyawn $_user"}
	ttk::button $button.2.i.xwave -text "xwave" -command { io.outgoing "xwave $_user"}
	ttk::button $button.2.j.xcackle -text "xcackle" -command { io.outgoing "xcackle $_user"}
	ttk::button $button.2.k.xgiggle -text "xgiggle" -command { io.outgoing "xgiggle $_user"}
	ttk::button $button2.1.a.xcry -text "xcry" -command { io.outgoing "xcry $_user"}
	ttk::button $button2.1.b.xpoke -text "xpoke" -command { io.outgoing "xpoke $_user"}
	ttk::button $button2.1.c.xshrug -text "xshrug" -command { io.outgoing "xshrug $_user"}
	ttk::button $button2.1.d.xblush -text "xblush" -command { io.outgoing "xblush $_user"}
	ttk::button $button2.1.e.xcringe -text "xcringe" -command { io.outgoing "xcringe $_user"}
	ttk::button $button2.1.f.xsmirk -text "xsmirk" -command { io.outgoing "xsmirk $_user"}
	ttk::button $button2.2.g.xnod -text "xnod" -command { io.outgoing "xnod $_user"}
	ttk::button $button2.2.h.xgrin -text "xgrin" -command { io.outgoing "xgrin $_user"}
	ttk::button $button2.2.i.xlaugh -text "xlaugh" -command { io.outgoing "xlaugh $_user"}
	ttk::button $button2.2.j.xsigh -text "xsigh" -command { io.outgoing "xsigh $_user"}
	ttk::button $button2.2.k.xchuckle -text "xchuckle" -command { io.outgoing "xchuckle $_user"}
	ttk::button $button.1.a.xkiss -text "xkiss" -command { io.outgoing "xkiss $_user"}
	ttk::button $button.1.b.xfrench -text "xfrench" -command { io.outgoing "xfrench $_user $_user"}
	ttk::button $button.1.c.xbow -text "xbow" -command { io.outgoing "xbow $_user"}
	ttk::button $button.1.d.xtongue -text "xtongue" -command { io.outgoing "xtongue $_user"}
	ttk::button $button.1.e.xspank -text "xspank" -command { io.outgoing "xspank $_user"}
	ttk::button $button.1.f.xhug -text "xhug" -command { io.outgoing "xhug $_user"}
	ttk::button $button.2.g.xeye -text "xeye" -command { io.outgoing "xeye $_user"}
	ttk::button $button.2.h.xthwap -text "xthwap" -command { io.outgoing "xthwap $_user"}
	ttk::button $button.2.i.xsuck -text "xsuck" -command { io.outgoing "xsuck $_user"}
	ttk::button $button.2.j.xmessages -text "xmessages" -command { io.outgoing "xmessages $_user"}
	ttk::button $button.2.k.xcommands -text "xcommands" -command { io.outgoing "xcommands $_user"}
	ttk::button $button2.1.b.xblink -text "xblink" -command { io.outgoing "xblink $_user"}
	ttk::button $button2.1.c.xsmooch -text "xsmooch" -command { io.outgoing "xsmooch $_user"}
	ttk::button $button2.1.d.xpat -text "xpat" -command { io.outgoing "xpat $_user"}
	ttk::button $button2.1.e.xlick -text "xlick" -command { io.outgoing "xlick $_user"}
	ttk::button $button2.1.f.xtouch -text "xtouch" -command { io.outgoing "xtouch $_user"}
	ttk::button $button2.2.g.xwiggle -text "xwiggle" -command { io.outgoing "xwiggle $_user"}
	ttk::button $button2.2.h.xwhuggle -text "xwhuggle" -command { io.outgoing "xwhuggle $_user"}
	ttk::button $button2.2.i.xlust -text "xlust" -command { io.outgoing "xlust $_user"}
	ttk::button $button2.2.j.xhi5 -text "xhi5" -command { io.outgoing "xhi5 $_user"}
	ttk::button $button2.2.k.xspoof -text "xspoof" -command { io.outgoing "xspoof $_user"}
	ttk::button $button.1.a.xbotto -text "xbotto" -command { io.outgoing "xbotto $_user"}
	ttk::button $button.1.b.xgasp -text "xgasp" -command { io.outgoing "xgasp $_user"}
	ttk::button $button.1.c.xth -text "xth" -command { io.outgoing "xth $_user"}
	ttk::button $button.1.d.xwall -text "xwall" -command { io.outgoing "xwall $_user"}
	ttk::button $button.1.e.xpeer -text "xpeer" -command { io.outgoing "xpeer $_user"}
	ttk::button $button.1.f.xpee -text "xpee" -command { io.outgoing "xpee $_user"}
	ttk::button $button.2.g.xsnicker -text "xsnicker" -command { io.outgoing "xsnicker $_user"}
	ttk::button $button.2.h.xhold -text "xhold" -command { io.outgoing "xhold $_user"}
	ttk::button $button.2.i.xcuddle -text "xcuddle" -command { io.outgoing "xcuddle $_user"}
	ttk::button $button.2.j.xfondle -text "xfondle" -command { io.outgoing "xfondle $_user"}
	ttk::button $button.2.k.xtickle -text "xtickle" -command { io.outgoing "xtickle $_user"}
	ttk::button $button2.1.a.xrofl -text "xrofl" -command { io.outgoing "xrofl $_user"}
	ttk::button $button2.1.b.xpinch -text "xpinch" -command { io.outgoing "xpinch $_user"}
	ttk::button $button2.1.c.xpoint -text "xpoint" -command { io.outgoing "xpoint $_user"}
	ttk::button $button2.1.d.xpurr -text "xpurr" -command { io.outgoing "xpurr $_user"}
	ttk::button $button2.1.e.xbrow -text "xbrow" -command { io.outgoing "xbrow $_user"}
	ttk::button $button2.1.f.xdance -text "xdance" -command { io.outgoing "xdance $_user"}
	ttk::button $button2.2.g.xpout -text "xpout" -command { io.outgoing "xpout $_user"}
	ttk::button $button2.2.h.xbeer -text "xbeer" -command { io.outgoing "xbeer $_user"}
	ttk::button $button2.2.i.xtypo -text "xtypo" -command { io.outgoing "xtypo $_user"}
	ttk::button $button2.2.j.xruffle -text "xruffle" -command { io.outgoing "xruffle $_user"}
	ttk::button $button2.2.k.xmosh -text "xmosh" -command { io.outgoing "xmosh $_user"}
	ttk::button $button.1.a.xpounce -text "xpounce" -command { io.outgoing "xpounce $_user"}
	ttk::button $button.1.b.xbarf -text "xbarf" -command { io.outgoing "xbarf $_user"}
	ttk::button $button.1.c.xcheer -text "xcheer" -command { io.outgoing "xcheer $_user"}
	ttk::button $button.1.d.xsmoke -text "xsmoke" -command { io.outgoing "xsmoke $_user"}
	ttk::button $button.1.e.xhuggle -text "xhuggle" -command { io.outgoing "xhuggle $_user"}
	ttk::button $button.1.f.xafk -text "xafk" -command { io.outgoing "xafk $_user"}
	ttk::button $button.2.g.xbbl -text "xbbl" -command { io.outgoing "xbbl $_user"}
	ttk::button $button.2.h.xbrb -text "xbrb" -command { io.outgoing "xbrb $_user"}
	ttk::button $button.2.i.xback -text "xback" -command { io.outgoing "xback $_user"}
	ttk::button $button.2.j.xcbow -text "xcbow" -command { io.outgoing "xcbow $_user"}
	ttk::button $button.2.k.xrbow -text "xrbow" -command { io.outgoing "xrbow $_user"}
	ttk::button $button2.1.a.xhat -text "xhat" -command { io.outgoing "xhat $_user"}
	ttk::button $button2.1.b.xbat -text "xbat" -command { io.outgoing "xbat $_user"}
	ttk::button $button2.1.c.xgoose -text "xgoose" -command { io.outgoing "xgoose $_user"}
	ttk::button $button2.1.d.xgrimple -text "xgrimple" -command { io.outgoing "xgrimple $_user"}
	ttk::button $button2.1.e.xgroan -text "xgroan" -command { io.outgoing "xgroan $_user"}
	ttk::button $button2.1.f.xgrope -text "xgrope" -command { io.outgoing "xgrope $_user"}
	ttk::button $button2.2.g.xidle -text "xidle" -command { io.outgoing "xidle $_user"}
	ttk::button $button2.2.h.xglare -text "xglare" -command { io.outgoing "xglare $_user"}
	ttk::button $button2.2.i.xgrowl -text "xgrowl" -command { io.outgoing "xgrowl $_user"}
	ttk::button $button2.2.j.xhowl -text "xhowl" -command { io.outgoing "xhowl $_user"}
	ttk::button $button2.2.k.xwhimper -text "xwhimper" -command { io.outgoing "xwhimper $_user"}
	ttk::button $button.1.a.xwhine -text "xwhine" -command { io.outgoing "xwhine $_user"}
	ttk::button $button.1.b.xbotto_old -text "xbotto_old" -command { io.outgoing "xbotto_old $_user"}
	ttk::button $button.1.c.xfrown -text "xfrown" -command { io.outgoing "xfrown $_user"}
	ttk::button $button.1.d.xfurrow -text "xfurrow" -command { io.outgoing "xfurrow $_user"}
	ttk::button $button.1.e.xbounce -text "xbounce" -command { io.outgoing "xbounce $_user"}
	ttk::button $button.1.f.xbeam -text "xbeam" -command { io.outgoing "xbeam $_user"}
	ttk::button $button.2.g.xbite -text "xbite" -command { io.outgoing "xbite $_user"}
	ttk::button $button.2.h.x711 -text "x711" -command { io.outgoing "x711 $_user"}
	ttk::button $button.2.i.xapplaud -text "xapplaud" -command { io.outgoing "xapplaud $_user"}
	ttk::button $button.2.j.xbkiss -text "xbkiss" -command { io.outgoing "xbkiss $_user"}
	ttk::button $button.2.k.xboggle -text "xboggle" -command { io.outgoing "xboggle $_user"}
	ttk::button $button2.1.a.xbstare -text "xbstare" -command { io.outgoing "xbstare $_user"}
	ttk::button $button2.1.b.xcoffee -text "xcoffee" -command { io.outgoing "xcoffee $_user"}
	ttk::button $button2.1.c.xcurtsey -text "xcurtsey" -command { io.outgoing "xcurtsey $_user"}
	ttk::button $button2.1.d.xcurtsy -text "xcurtsy" -command { io.outgoing "xcurtsy $_user"}
	ttk::button $button2.1.e.xdblush -text "xdblush" -command { io.outgoing "xdblush $_user"}
	ttk::button $button2.1.f.xdkiss -text "xdkiss" -command { io.outgoing "xdkiss $_user"}
	ttk::button $button2.2.g.xfdl -text "xfdl" -command { io.outgoing "xfdl $_user"}
	ttk::button $button2.2.h.xgirn -text "xgirn" -command { io.outgoing "xgirn $_user"}
	ttk::button $button2.2.i.xglance -text "xglance" -command { io.outgoing "xglance $_user"}
	ttk::button $button2.2.j.xhmm -text "xhmm" -command { io.outgoing "xhmm $_user"}
	ttk::button $button2.2.k.xhrm -text "xhrm" -command { io.outgoing "xhrm $_user"}
	ttk::button $button.1.a.ximp -text "ximp" -command { io.outgoing "ximp $_user"}
	ttk::button $button.1.b.xismile -text "xismile" -command { io.outgoing "xismile $_user"}
	ttk::button $button.1.c.xiwhistle -text "xiwhistle" -command { io.outgoing "xiwhistle $_user"}
	ttk::button $button.1.d.xlol -text "xlol" -command { io.outgoing "xlol $_user"}
	ttk::button $button.1.e.xpet -text "xpet" -command { io.outgoing "xpet $_user"}
	ttk::button $button.1.f.xquiver -text "xquiver" -command { io.outgoing "xquiver $_user"}
	ttk::button $button.2.g.xroll -text "xroll" -command { io.outgoing "xroll $_user"}
	ttk::button $button.2.h.xrollback -text "xrollback" -command { io.outgoing "xrollback $_user"}
	ttk::button $button.2.i.xrumba -text "xrumba" -command { io.outgoing "xrumba $_user"}
	ttk::button $button.2.j.xrumple -text "xrumple" -command { io.outgoing "xrumple $_user"}
	ttk::button $button.2.k.xsalute -text "xsalute" -command { io.outgoing "xsalute $_user"}
	ttk::button $button2.1.a.xscotch -text "xscotch" -command { io.outgoing "xscotch $_user"}
	ttk::button $button2.1.b.xsgrin -text "xsgrin" -command { io.outgoing "xsgrin $_user"}
	ttk::button $button2.1.c.xshiver -text "xshiver" -command { io.outgoing "xshiver $_user"}
	ttk::button $button2.1.d.xshudder -text "xshudder" -command { io.outgoing "xshudder $_user"}
	ttk::button $button2.1.e.xroar -text "xroar" -command { io.outgoing "xroar $_user"}
	ttk::button $button2.1.f.xsing -text "xsing" -command { io.outgoing "xsing $_user"}
	ttk::button $button2.2.g.xslurp -text "xslurp" -command { io.outgoing "xslurp $_user"}
	ttk::button $button2.2.h.xsnarl -text "xsnarl" -command { io.outgoing "xsnarl $_user"}
	ttk::button $button2.2.i.xsniff -text "xsniff" -command { io.outgoing "xsniff $_user"}
	ttk::button $button2.2.j.xsniffle -text "xsniffle" -command { io.outgoing "xsniffle $_user"}
	ttk::button $button2.2.k.xsnuggle -text "xsnuggle" -command { io.outgoing "xsnuggle $_user"}
	ttk::button $button.1.a.xspit -text "xspit" -command { io.outgoing "xspit $_user"}
	ttk::button $button.1.b.xsqueal -text "xsqueal" -command { io.outgoing "xsqueal $_user"}
	ttk::button $button.1.c.xsweet -text "xsweet" -command { io.outgoing "xsweet $_user"}
	ttk::button $button.1.d.xvnod -text "xvnod" -command { io.outgoing "xvnod $_user"}
	ttk::button $button.1.e.xwaltz -text "xwaltz" -command { io.outgoing "xwaltz $_user"}
	ttk::button $button.1.f.xwgrin -text "xwgrin" -command { io.outgoing "xwgrin $_user"}
	ttk::button $button.2.g.xwhistle -text "xwhistle" -command { io.outgoing "xwhistle $_user"}
	ttk::button $button.2.h.xwhoop -text "xwhoop" -command { io.outgoing "xwhoop $_user"}
	ttk::button $button.2.i.xwince -text "xwince" -command { io.outgoing "xwince $_user"}
	ttk::button $button.2.j.xwoo -text "xwoo" -command { io.outgoing "xwoo $_user"}
	ttk::button $button.2.k.xwow -text "xwow" -command { io.outgoing "xwow $_user"}
	ttk::button $button2.1.a.xyeehaw -text "xyeehaw" -command { io.outgoing "xyeehaw $_user"}
	ttk::button $button2.1.b.xzerbert -text "xzerbert" -command { io.outgoing "xzerbert $_user"}
	ttk::button $button2.1.c.xegrin -text "xegrin" -command { io.outgoing "xegrin $_user"}
	ttk::button $button2.1.d.xfpull -text "xfpull" -command { io.outgoing "xfpull $_user"}
	ttk::button $button2.1.e.xmoan -text "xmoan" -command { io.outgoing "xmoan $_user"}
	ttk::button $button2.1.f.xrhug -text "xrhug" -command { io.outgoing "xrhug $_user"}
	ttk::button $button2.2.g.xslap -text "xslap" -command { io.outgoing "xslap $_user"}
	ttk::button $button2.2.h.xhump -text "xhump" -command { io.outgoing "xhump $_user"}
	pack $button.1 -side top
	pack $button.2
	pack $button.e
	pack $button.e.e -fill both
	pack $button.1.a -side right
	pack $button.1.b -side right
	pack $button.1.c -side right
	pack $button.1.d -side right
	pack $button.1.e -side right
	pack $button.1.f -side right
	pack $button.2.g -side right
	pack $button.2.h -side right
	pack $button.2.i -side right
	pack $button.2.j -side right
	pack $button.2.k -side right
	pack $button2.1 -side top
	pack $button2.2 -side bottom
	pack $button2.1.a -side right
	pack $button2.1.b -side right
	pack $button2.1.c -side right
	pack $button2.1.d -side right
	pack $button2.1.e -side right
	pack $button2.1.f -side right
	pack $button2.2.g -side right
	pack $button2.2.h -side right
	pack $button2.2.i -side right
	pack $button2.2.j -side right
	pack $button2.2.k -side right
	pack $button2.2.l -side right
	pack $button.1.d.xthink
	pack $button.1.e.xsmile
	pack $button.1.f.xcomfort
	pack $button.2.g.xwink
	pack $button.2.h.xyawn
	pack $button.2.i.xwave
	pack $button.2.j.xcackle
	pack $button.2.k.xgiggle
	pack $button2.1.a.xcry
	pack $button2.1.b.xpoke
	pack $button2.1.c.xshrug
	pack $button2.1.d.xblush
	pack $button2.1.e.xcringe
	pack $button2.1.f.xsmirk
	pack $button2.2.g.xnod
	pack $button2.2.h.xgrin
	pack $button2.2.i.xlaugh
	pack $button2.2.j.xsigh
	pack $button2.2.k.xchuckle
	pack $button.1.a.xkiss
	pack $button.1.b.xfrench
	pack $button.1.c.xbow
	pack $button.1.d.xtongue
	pack $button.1.e.xspank
	pack $button.1.f.xhug
	pack $button.2.g.xeye
	pack $button.2.h.xthwap
	pack $button.2.i.xsuck
	pack $button.2.j.xmessages
	pack $button.2.k.xcommands
	pack $button2.1.b.xblink
	pack $button2.1.c.xsmooch
	pack $button2.1.d.xpat
	pack $button2.1.e.xlick
	pack $button2.1.f.xtouch
	pack $button2.2.g.xwiggle
	pack $button2.2.h.xwhuggle
	pack $button2.2.i.xlust
	pack $button2.2.j.xhi5
	pack $button2.2.k.xspoof
	pack $button.1.a.xbotto
	pack $button.1.b.xgasp
	pack $button.1.c.xth
	pack $button.1.d.xwall
	pack $button.1.e.xpeer
	pack $button.1.f.xpee
	pack $button.2.g.xsnicker
	pack $button.2.h.xhold
	pack $button.2.i.xcuddle
	pack $button.2.j.xfondle
	pack $button.2.k.xtickle
	pack $button2.1.a.xrofl
	pack $button2.1.b.xpinch
	pack $button2.1.c.xpoint
	pack $button2.1.d.xpurr
	pack $button2.1.e.xbrow
	pack $button2.1.f.xdance
	pack $button2.2.g.xpout
	pack $button2.2.h.xbeer
	pack $button2.2.i.xtypo
	pack $button2.2.j.xruffle
	pack $button2.2.k.xmosh
	pack $button.1.a.xpounce
	pack $button.1.b.xbarf
	pack $button.1.c.xcheer
	pack $button.1.d.xsmoke
	pack $button.1.e.xhuggle
	pack $button.1.f.xafk
	pack $button.2.g.xbbl
	pack $button.2.h.xbrb
	pack $button.2.i.xback
	pack $button.2.j.xcbow
	pack $button.2.k.xrbow
	pack $button2.1.a.xhat
	pack $button2.1.b.xbat
	pack $button2.1.c.xgoose
	pack $button2.1.d.xgrimple
	pack $button2.1.e.xgroan
	pack $button2.1.f.xgrope
	pack $button2.2.g.xidle
	pack $button2.2.h.xglare
	pack $button2.2.i.xgrowl
	pack $button2.2.j.xhowl
	pack $button2.2.k.xwhimper
	pack $button.1.a.xwhine
	pack $button.1.b.xbotto_old
	pack $button.1.c.xfrown
	pack $button.1.d.xfurrow
	pack $button.1.e.xbounce
	pack $button.1.f.xbeam
	pack $button.2.g.xbite
	pack $button.2.h.x711
	pack $button.2.i.xapplaud
	pack $button.2.j.xbkiss
	pack $button.2.k.xboggle
	pack $button2.1.a.xbstare
	pack $button2.1.b.xcoffee
	pack $button2.1.c.xcurtsey
	pack $button2.1.d.xcurtsy
	pack $button2.1.e.xdblush
	pack $button2.1.f.xdkiss
	pack $button2.2.g.xfdl
	pack $button2.2.h.xgirn
	pack $button2.2.i.xglance
	pack $button2.2.j.xhmm
	pack $button2.2.k.xhrm
	pack $button.1.a.ximp
	pack $button.1.b.xismile
	pack $button.1.c.xiwhistle
	pack $button.1.d.xlol
	pack $button.1.e.xpet
	pack $button.1.f.xquiver
	pack $button.2.g.xroll
	pack $button.2.h.xrollback
	pack $button.2.i.xrumba
	pack $button.2.j.xrumple
	pack $button.2.k.xsalute
	pack $button2.1.a.xscotch
	pack $button2.1.b.xsgrin
	pack $button2.1.c.xshiver
	pack $button2.1.d.xshudder
	pack $button2.1.e.xroar
	pack $button2.1.f.xsing
	pack $button2.2.g.xslurp
	pack $button2.2.h.xsnarl
	pack $button2.2.i.xsniff
	pack $button2.2.j.xsniffle
	pack $button2.2.k.xsnuggle
	pack $button.1.a.xspit
	pack $button.1.b.xsqueal
	pack $button.1.c.xsweet
	pack $button.1.d.xvnod
	pack $button.1.e.xwaltz
	pack $button.1.f.xwgrin
	pack $button.2.g.xwhistle
	pack $button.2.h.xwhoop
	pack $button.2.i.xwince
	pack $button.2.j.xwoo
	pack $button.2.k.xwow
	pack $button2.1.a.xyeehaw
	pack $button2.1.b.xzerbert
	pack $button2.1.c.xegrin
	pack $button2.1.d.xfpull
	pack $button2.1.e.xmoan
	pack $button2.1.f.xrhug
	pack $button2.2.g.xslap
	pack $button2.2.h.xhump
}
