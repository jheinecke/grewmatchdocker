FROM ubuntu:20.04

# build
# docker build -t grew:latest .

# run
# docker run --rm -p 8001:8000 -p 8899:8899 --hostname localhost --name grewtest -it grew 
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
	&& apt-get install -y ocaml-findlib \
	&& apt-get install -y pkg-config openssl libssl-dev \
	&& apt-get install -y libpcre3-dev sqlite3 zlib1g-dev \
	&& apt-get install -y libgmp3-dev libsqlite3-dev \
	&& apt-get install -y libcairo-ocaml-dev


RUN opam init --disable-sandboxing
RUN opam switch create 4.13.1 4.13.1

RUN ocamlc -v
RUN opam install --yes ssl.0.5.9  # force the version number, 0.5.10 is broken

RUN opam remote add grew "http://opam.grew.fr"
RUN opam install --yes containers 
RUN opam install --yes grew grewpy

RUN opam install --yes ocsipersist-sqlite 
#RUN opam install --yes ocsipersist-dbm

RUN opam install --yes libcaml-dep2pict fileutils
#RUN opam install --yes libcaml-grew
RUN opam install --yes eliom

WORKDIR /opt

RUN git clone https://gitlab.inria.fr/grew/grew_match_back.git
RUN git clone https://gitlab.inria.fr/grew/grew_match.git

RUN cat /opt/grew_match_back/Makefile.options \
	| sed 's/PERSISTENT_DATA_BACKEND = dbm/PERSISTENT_DATA_BACKEND = sqlite/' \
	> m && mv m /opt/grew_match_back/Makefile.options

#	| sed 's:<log>__TODO__:<log>/opt/grew_match_back/log:' \
#	| sed 's:<log>__TODO__:<log>/log:' \
RUN cat /opt/grew_match_back/gmb.conf.in__TEMPLATE \
	| sed 's:<log>__TODO__:<log>/log:' \
	| sed 's:<extern>__TODO__:<extern>/opt/grew_match_back/static:' \
	| sed 's:<corpora>__TODO__:<corpora>/opt/grew_match_back/corpora:' \
	| sed 's:<config>__TODO__:<config>/opt/grew_match/corpora/config.json:' \
	> /opt/grew_match_back/gmb.conf.in


#COPY config.json /opt/grew_match/corpora/config.json
#COPY welsh.json /opt/grew_match_back/corpora/welsh.json


#RUN git clone https://github.com/UniversalDependencies/UD_Welsh-CCG.git
#RUN /root/.opam/4.13.1/bin/grew compile -grew_match_server /opt/grew_match/meta   -i /opt/grew_match_back/corpora/welsh.json

RUN opam switch && eval $(opam env)
RUN ocamlc -v
RUN mkdir /opt/grew_match_back/log
RUN mkdir /opt/grew_match_back/corpora
ENV PATH=${PATH}:/root/.opam/4.13.1/bin

# todo: use /log and /corpora
#           logs                        data
# VOLUME [ "/opt/grew_match_back/log", "/data" ]

EXPOSE 8000

COPY startscript.sh .
RUN chmod +x startscript.sh

CMD ["/opt/startscript.sh"]
