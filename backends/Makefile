.SUFFIXES: .tex .stm .sml .dvi .ps .pdf .html

# you can call me as
# make xml.pdf BASE=~/projects/TM/XTM/slides/utils/ MAPS=file:~/projects/TM/maps/

# set this to the directory where you hold your maps
MAPS = "file:"`pwd`"/../maps/"

VERBOSE=
#VERBOSE=--verbose

BASE = `pwd`

PWD := $(shell echo `pwd`)

PROSPERSTYLE = 'autumn'
HTMLSTYLE    = '${BASE}/ugly.css'

# with prosper you can have the following styles:
#     frames lignesbleues azure darkblue alienglow autumn
.sml.tex:
	(cd ${BASE}/prosper; xsltproc ${VERBOSE} --param style "${PROSPERSTYLE}" prosper.xslt ${PWD}/$<  > ${PWD}/$@)
	mv $@ /tmp/tmslide
	cat /tmp/tmslide   | perl -p -e 's/([%_\#&])/\\$$1/g' > /tmp/tmslide-2
	cat /tmp/tmslide-2 | perl -p -e 's#\\begin{itemize}\\end{itemize}##' > $@
	rm /tmp/tmslide*

.sml.html:
	(cd ${BASE}/html; xsltproc ${VERBOSE} --param style "${HTMLSTYLE}" html.xslt ${PWD}/$<  > ${PWD}/$@)

.tex.dvi:
	latex $<

.dvi.ps:
	dvips -o $@ $<

.ps.pdf:
	ps2pdf $<

.stm.sml:
	cat $< | stm2sml.pl --urlbase=${MAPS} > $@

clean:
	rm -rf *.sml *.tex *.pdf *.ps *.aux *.log *.dvi *.out *.html *~ 

dist:
	tar zcvf slides.tgz *.pdf *.sml *.html *.stm Makefile
