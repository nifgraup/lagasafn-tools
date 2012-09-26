#!/bin/bash

#todo:
#	remove newer timestamping format in html
#	fix commit message
#		timestamp
#		(Nafn á forseta Íslands)
#	use github pages for rendering html
#	normalize html
#		html tidy
#		use of <a, <!a and <!!a

wget -N --no-remove-listing http://althingi.is/vefur/eldri-utg.html
grep -o 'lagas/.*/allt.zip' eldri-utg.html | awk '{ print "http://althingi.is/"$0; }' > urls.txt

wget -m -i urls.txt

(
	git init lagasafn;
	cd lagasafn;
	git config user.name "Forseti Íslands";
	git config user.email "forseti@forseti.is";
	git remote add origin https://nifgraup@github.com/nifgraup/lagasafn.git
)

for i in $( ls althingi.is/lagas/ );
do
	(
		cd lagasafn &&
		git rm -r --ignore-unmatch * &&
		unzip ../althingi.is/lagas/$i/allt.zip &&

		#filters:
		#
		find . -name "*.html" | while read file; do
			LC_ALL=en_US sed -i '/Prenta.*tveimur/d' $file #remove timestamp
			sed -i '/<!-- Virk vefmaeling byrjar/,$d' $file #Remove teljar.is & google analytics
		done

		git add . && git commit -m "Útgáfa $i";
	)
done

