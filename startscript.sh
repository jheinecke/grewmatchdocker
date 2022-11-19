#!/bin/bash

# start front-end in background
python3 -m http.server &

# copy config files from mounted volumes to the place where they are expected
cp /data/config.json /home/grewmatch/grew_match/corpora/config.json
cp /data/lang.json   /home/grewmatch/grew_match_back/corpora/lang.json

# compile treebank for use with grew
grew compile -grew_match_server /home/grewmatch/grew_match/meta   -i /home/grewmatch/grew_match_back/corpora/lang.json

# initialise opam environmant variables
eval $(opam env)

# go where the makefiles are
pushd /home/grewmatch/grew_match_back

# run back-end
make clean
make test.opt

