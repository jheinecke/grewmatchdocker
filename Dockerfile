FROM ubuntu:20.04

# build
# docker build--build-arg UID=$(id -u) --build-arg GID=$(id -g)  -t grew:latest .

# run
# docker run --rm -p 8001:8000 -p 8899:8899 --hostname localhost --name grewtest -v $(pwd)/config:/data -v $(pwd)/log:/log -it grew 

LABEL maintainer="Johannes Heinecke <johannes.heinecke@orange.com>"
LABEL org.label-schema.name="Grew Match server"
LABEL org.label-schema.version="2.0"
LABEL org.label-schema.schema_version="RC1"

ENV TZ="Europe/Paris"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone    

RUN apt-get update \
	&& apt-get install -y git \
	&& apt-get install -y opam \
	&& apt-get install -y make wget m4 unzip librsvg2-bin curl bubblewrap \
	&& apt-get install -y pkg-config openssl libssl-dev \
	&& apt-get install -y libpcre3-dev sqlite3 zlib1g-dev \
	&& apt-get install -y libgmp3-dev libsqlite3-dev \
	&& apt-get install -y libcairo-dev \
	&& apt-get install -y graphviz

RUN apt-get clean && apt-get autoremove

# default uid/group, change with --build-arg UID=<newvalue>
ARG UID=1000
ARG GID=1000

# create "local" user
RUN groupadd -g ${GID} grew
RUN useradd -u ${UID} -g ${GID} -m -s /bin/bash grewmatch
USER grewmatch
RUN id
RUN ls -la /home/grewmatch
WORKDIR /home/grewmatch

# install opam related tools/packages
RUN opam init --disable-sandboxing
RUN opam switch create 4.14.0 4.14.0

# TODO does not work like this, the output of opam env must be written to ENV
# RUN eval $(opam env)
RUN opam remote add grew "http://opam.grew.fr"
RUN eval $(opam env) && opam install --yes libcaml-dep2pict grew
RUN eval $(opam env) && opam install --yes fileutils ocsipersist-sqlite eliom


RUN git clone https://gitlab.inria.fr/grew/grew_match_back.git
RUN git clone https://gitlab.inria.fr/grew/grew_match.git

RUN sed -i 's/PERSISTENT_DATA_BACKEND = dbm/PERSISTENT_DATA_BACKEND = sqlite/' \
	/home/grewmatch/grew_match_back/Makefile.options

RUN cat /home/grewmatch/grew_match_back/gmb.conf.in__TEMPLATE \
	| sed 's:<log>__LOG__:<log>/log:' \
	| sed 's:<extern>__EXTERN__:<extern>/home/grewmatch/grew_match_back/static:' \
	| sed 's:<corpora>__CORPORA__:<corpora>/home/grewmatch/grew_match_back/corpora:' \
	| sed 's:<config>__CONFIG__:<config>/home/grewmatch/grew_match/corpora/config.json:' \
	> /home/grewmatch/grew_match_back/gmb.conf.in

# needed to put (head/dependent) tables, compiled out of treebanks at runtime
RUN mkdir /home/grewmatch/grew_match/meta
RUN mkdir /home/grewmatch/grew_match_back/corpora
# needed for save button
RUN mkdir -p /home/grewmatch/grew_match_back/static/shorten

VOLUME [ "/log", "/data" ]

EXPOSE 8000
COPY --chown=grewmatch:grew startscript.sh .


RUN wget https://gitlab.inria.fr/grew/grew_match_config/-/archive/master/grew_match_config-master.tar.gz
RUN tar -zxf grew_match_config-master.tar.gz
RUN mv grew_match_config-master/universal/UD /home/grewmatch/grew_match/corpora/UD
RUN mv grew_match_config-master/universal/SUD /home/grewmatch/grew_match/corpora/SUD
RUN mv grew_match_config-master/universal/snippets* /home/grewmatch/grew_match/corpora/
RUN mv grew_match_config-master/semantics/amr /home/grewmatch/grew_match/corpora/amr


RUN chmod 755 startscript.sh

ENV PATH=${PATH}:/home/grewmatch/.opam/4.14.0/bin
RUN echo $PATH

CMD ["/home/grewmatch/startscript.sh"]
