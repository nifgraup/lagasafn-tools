#!/bin/bash

# TODO
#	markdown
#		fix infinitive loop in pandoc
#		fix html links to markdown links. Nb. don't convert external links to althingi.is
#	normalize html
#		skip unnecessary html sanitation, let pandoc take care of it.
#		remove newer timestamping format in html
#	fix commit message
#		(Nafn á forseta Íslands)
#	tag (& sign) releases


# Download zip archives
wget -q -N --no-remove-listing http://althingi.is/vefur/eldri-utg.html
grep -o 'lagas/.*/allt.zip' eldri-utg.html | xargs printf "http://althingi.is/%s\n" > urls.txt
wget -q -m -i urls.txt


# Create git repo and configure it
(
	git init lagasafn
	cd lagasafn
	git config user.name "Forseti Íslands"
	git config user.email "forseti@forseti.is"
	git remote add origin https://nifgraup@github.com/nifgraup/lagasafn.git
)

for i in $( ls althingi.is/lagas/ );
do
	(
		echo "Creating commit for version $i"
		cd lagasafn
		git rm -q -r --ignore-unmatch *
		unzip -q ../althingi.is/lagas/$i/allt.zip

		COMMITDATE=`find -name lagas.nr.html | xargs iconv -f iso-8859-1 -t utf-8 | grep tgáfa | grep -o  "\([[:digit:]]\*\. \)\?[[:alpha:]]* [[:digit:]][[:digit:]][[:digit:]][[:digit:]]" | sed -e 's/\.//' -e 's/júlí/july/' -e 's/október/october/' -e 's/janúar/january/' -e 's/febrúar/february/' -e 's/maí/may/' -e 's/júní/june/' -e 's/mars/march/' -e 's/^\([[:alpha:]]\)/1 \1/'`
		
		# html normalizing
		find . -name "*.html" | while read file; do
			# remove carriage return, required for removal of lines at eof
			# add newline at end of file, will be removed later if not needed
			sed -i -e 's/\r//g' \
				-e '$G' \
				$file
			
			# remove timestamp
			# remove links to althingi.is with info about the process
			# remove extra newlines at eof
			# remove teljar.is & google analytics
			# remove added exclamation mark in links
			# remove absolut link to althingi.is and and replace with a relative link in this dir
			# remove html & body tags when present at the end of the last line
			# add head tag if missing
			iconv -f iso-8859-1 $file | sed -e '/Prenta.*tveimur/d' \
					-e '/Ferill m.lsins . Al.ingi/d' \
					-e :a -e '/^\n*$/{$d;N;};/\n$/ba' \
					-e '/<!-- Virk vefm..\?ling byrjar/,$d' \
					-e 's/<!*a/<a/g' \
					-e "s/http:\/\/www.althingi.is\/lagas\/$i\///g" \
					-e 's/\(<\/body>\)\?<\/html>//' \
					-e 's/\(<head>\)\?<title>/<head><title>/' -e 's/<\/title>\(<\/head>\)\?/<\/title><\/head>/' \
					| pandoc +RTS -K1844674407370955161 -RTS -f html -t markdown > `dirname $file`/`basename $file .html`.md
			rm $file
		done

		ln -s kaflar.md README.md
		git add .
		git commit -q -m "Útgáfa $i" --date "`date --date "$COMMITDATE"`"
	)
done

