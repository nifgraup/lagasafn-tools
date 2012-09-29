#!/bin/bash

# TODO
#	normalize html
#		remove newer timestamping format in html
#		html tidy
#	fix commit message
#		timestamp
#		(Nafn á forseta Íslands)
#	use github pages for rendering html
#	tag (& sign) releases


# Download zip archives
wget -N --no-remove-listing http://althingi.is/vefur/eldri-utg.html
grep -o 'lagas/.*/allt.zip' eldri-utg.html | awk '{ print "http://althingi.is/"$0; }' > urls.txt
wget -m -i urls.txt


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
		cd lagasafn
		git rm -q -r --ignore-unmatch *
		unzip -q ../althingi.is/lagas/$i/allt.zip

		# html normalizing
		find . -name "*.html" | while read file; do
			chmod 644 $file
	
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
			LC_ALL=en_US sed -i -e '/Prenta.*tveimur/d' \
					-e '/Ferill m.lsins . Al.ingi/d' \
					-e :a -e '/^\n*$/{$d;N;};/\n$/ba' \
					-e '/<!-- Virk vefm..\?ling byrjar/,$d' \
					-e 's/<!*a/<a/g' \
					-e "s/http:\/\/www.althingi.is\/lagas\/$i\///g" \
					-e 's/<\/body><\/html>//' \
					$file
#			tidy -q -m $file
		done

		git add .
		git commit -m "Útgáfa $i"
	)
done

