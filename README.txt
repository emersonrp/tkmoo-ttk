tkmoo-ttk is a fork of tkmoo-light <http://www.awns.com/tkMOO-light> with
some additions from tkmoo-se <http://sourceforge.net/projects/tkmoo-se/>.  It
attempts to update most of the UI elements to the ttk widget set so they look
and act like it's 2002 instead of 1995.  Baby steps, right?

Also planned are various updates to integrate better with modern desktop OSes,
xdg support for Linux et al, clean out MacOS Classic cruft and let OSX act like
the Unix it wants to be, etc etc.  It'd be nice to have this look and act like
an actual application, ne?  While we're modernizing, we might angle toward using
a Makefile instead of a 'build' script, for instance.

I've added in tkmoo-SE's giant collection of approximately every plugin ever,
and started a couple new ones of my own.  In general, this is borrowed and
plundered from several sources, often second- or third- hand.  I hope to
document this better and give appropriate credit as I pare it down to what will
eventually actually be part of it.

The extra plugins and various experiments and hacks require a few more packages
than the original tkMOO-light did, the mmedia plugin in particular wanting Img,
snack, and snackogg.  If installing those is problematic, remove
plugins/mmedia.tcl.  The hope is eventually to make that a little cleaner.

There are some known issues, and like all forks of tkmoo-light, it had a giant
flurry of activity once and since then is basically unmaintained.  You're
welcome to use it, and pull requests are encouraged.  Bug reports are certainly
welcome, but the vicissitudes of my attention mean there's no guarantee of me
fixing them.  Can't hurt to ask, though.

tkmoo-ttk is released under the same license as tkMOO-light; please read
LICENCE.txt for details.
