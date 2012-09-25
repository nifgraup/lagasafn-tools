#!/bin/bash

#todo:
#	fix commit message
#		timestamp
#		Nafn á forseta Íslands

wget http://althingi.is/vefur/eldri-utg.html
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
	echo $i > lagasafn/version
	( cd lagasafn; git add version; git commit -m "Útgáfa $i"; )
done

CURRDIR=`pwd`
(
	cd lagasafn;
	git filter-branch --tree-filter "unzip ${CURRDIR}/althingi.is/lagas/`cat version`/allt.zip"
)

