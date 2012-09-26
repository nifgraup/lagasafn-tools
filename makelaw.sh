#!/bin/bash

#todo:
#	fix commit message
#		timestamp
#		Nafn á forseta Íslands

wget -N --no-remove-listing http://althingi.is/vefur/eldri-utg.html
grep -o 'lagas/.*/allt.zip' eldri-utg.html | awk '{ print "http://althingi.is/"$0; }' > urls.txt

wget -m -i urls.txt

(
	git init lagasafn;
	cd lagasafn;
	git config user.name "Forseti Íslands";
	git config user.email "forseti@forseti.is";
)

for i in $( ls althingi.is/lagas/ );
do
	(
		cd lagasafn &&
		git rm -r --ignore-unmatch * &&
		unzip ../althingi.is/lagas/$i/allt.zip &&

		#filters:
		#
		#Remove teljar.is & google analytics
		find . -name "*.html" | while read file; do
			sed -i '/<!-- Virk vefmaeling byrjar/,$d' $file
		done

		git add . && git commit -m "Útgáfa $i";
	)
done

