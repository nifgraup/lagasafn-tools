#!/bin/bash

# TODO
#	normalize html
#		remove newer timestamping format in html
#		remove "Ferill málsins á Alþingi" (or include it from the beginning)
#		html tidy
#		use of <a, <!a and <!!a
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
		git rm -r --ignore-unmatch *
		unzip ../althingi.is/lagas/$i/allt.zip

		# html normalizing
		find . -name "*.html" | while read file; do
			#remove timestamp
			#remove teljar.is & google analytics
			LC_ALL=en_US sed -i -e '/Prenta.*tveimur/d' \
					    -e '/Ferill m.lsins . Al.ingi/d' \
			                    -e '/<!-- Virk vefmaeling byrjar/,$d' $file
		done

		git add .
		git commit -m "Útgáfa $i"
	)
done

