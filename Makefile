first=tidy-stamp
last=msg-stamp
all: ${last}

.PHONY: prepare clean push fastrepo remove-fastrepo

importzips=/usr/bin/env python /usr/share/doc/git/contrib/fast-import/import-zips.py
repo=lagasafn.git
git=git --git-dir ${repo}

prepare:
	wget -q -N --no-remove-listing http://althingi.is/lagasafn/zip-skra-af-lagasafni
	grep -o 'lagasafn/.*/allt.zip' zip-skra-af-lagasafni | xargs printf "http://althingi.is/%s\n" > urls.txt
	wget -q -m -i urls.txt

${repo}: urls.txt
	${git} init --bare
	${git} remote add origin https://nifgraup@github.com/nifgraup/lagasafn.git || true
	${git} branch -D import-zips || true
	${git} tag | xargs ${git} tag -d
	cd ${repo} && ${importzips} ../althingi.is/lagasafn/zip/*/allt.zip || true

${first}: ${repo}
	${git} branch -f $@ import-zips
	${git} filter-branch -f --tree-filter "git ls-files '*.html' | \
	parallel -m tidy -m --wrap 0 -f /dev/null || true" $@
	touch $@

iconv-stamp: ${first}
	${git} branch -f $@ $<
	${git} filter-branch -f --tree-filter "git ls-files '*.html' | \
	parallel -N1 'iconv -f iso8859-1 {} -o {}.new; mv {}.new {}'" $@
	touch $@

normalizehtml-stamp: iconv-stamp
	${git} branch -f $@ $<
	${git} filter-branch -f --tree-filter "git ls-files '*.html' | \
	xargs sed -i -e '/Prenta.*tveimur/d' -e '/Ferill m.*lsins .* Al.*ingi/d' \
	-e '/<!-- Virk vefm.*ling byrjar/,$$$$d'" $@
	touch $@

pandoc-stamp: normalizehtml-stamp
	${git} branch -f $@ $<
	${git} filter-branch -f --tree-filter "git ls-files '*.html' | \
	sed 's/.html//' | parallel -N1 'pandoc +RTS -K1844674407370955161 -RTS -f html -t textile -o {}.textile {}.html; rm {}.html'" $@
	touch $@

normalizetextile-stamp: pandoc-stamp
	${git} branch -f $@ $<
	${git} filter-branch -f --tree-filter "git ls-files '*.textile' | \
	xargs sed -i -e 's/![^!]*sk.jpg!/■/g' -e 's/![^!]*hk.jpg!/□/g' \
  -e 's/!!//g'" $@
	touch $@

${last}: normalizetextile-stamp
	${git} branch -f $@ $<
	${git} filter-branch -f --env-filter "\
	export GIT_AUTHOR_NAME='Forseti Íslands'; \
	export GIT_AUTHOR_EMAIL='forseti@forseti.is'; \
	export GIT_COMMITTER_NAME='Forseti Íslands'; \
	export GIT_COMMITTER_EMAIL='forseti@forseti.is'" $@
	touch $@

push: ${last}
	${git} push -f origin ${last}:master

fastrepo: ${first}
	${git} branch -f ${first}-backup ${first}
	${git} branch -f ${first} import-zips
	${git} filter-branch -f --index-filter "git ls-files '*.html' | \
	grep -v 1972073.html | xargs git rm" ${first}
	touch ${first}

remove-fastrepo:
	${git} branch -f ${first} ${first}-backup
	${git} branch -D ${first}-backup
	touch ${first}

clean:
	rm -rf *-stamp ${repo}
