.SUFFIXES: .tex .stm .sml .dvi .ps .pdf

# set this to the directory where you hold your maps
MAPS = "file:"`pwd`"/../maps/"


# with prosper you can have the following styles:
#     frames lignesbleues azure darkblue alienglow autumn
.sml.tex:
	(cd prosper; xsltproc --param style "'autumn'" prosper.xslt ../$<  > ../$@)
	mv $@ /tmp/tmslide
	cat /tmp/tmslide   | perl -p -e 's/([%_\#&])/\\$$1/g' > /tmp/tmslide-2
	cat /tmp/tmslide-2 | perl -p -e 's#\\begin{itemize}\\end{itemize}##' > $@
	rm /tmp/tmslide*

.tex.dvi:
	latex $<

.dvi.ps:
	dvips $<

.ps.pdf:
	ps2pdf $<

.stm.sml:
	cat $< | stm2sml.pl --tmbase=${MAPS} > $@

clean:
	rm -rf *.sml *.tex *.pdf *.ps *.aux *.log *.dvi *.out *~

