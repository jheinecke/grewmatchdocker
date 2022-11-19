#!/bin/bash

python3 -m http.server &

# modify 
#  /opt/grew_match/corpora/config.json
# and
#  /opt/grew_match_back/corpora/welsh.json
# according the data in $1 and $2
# $1 "UD_Lang-TB", e.g. "UD_Welsh-CCG"
# $2 config: "ud" or "sud"

#cat /opt/grew_match/corpora/config.json \
#    | jq ".default = \"${1}@master\"" \
#    | jq ".groups[0].default = \"${1}@master\"" \

cp /data/config.json /opt/grew_match/corpora/config.json
cp /data/lang.json   /opt/grew_match_back/corpora/lang.json

#/root/.opam/4.13.1/bin/grew
grew compile -grew_match_server /opt/grew_match/meta   -i /opt/grew_match_back/corpora/lang.json


eval $(opam env)
pushd /opt/grew_match_back
make clean
make test.opt
