clean:
	-rm -f *.dcu
	-rm -f *.~pas *.pas~ *.~xfm *.xfm~ *.~ddp *.ddp
	-rm -f Inhunmi
	convert -i -t *.xfm

Inhunmi:
	convert -i -b *.xfm
	dcc Inhunmi.dpr
