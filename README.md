# Dockerfile for http://match.grew.fr

## Build
```
docker build -t grew_match:latest .
```

The container runs using uid 1000. So the directories outside the container where grewmatch writes to (compiling treebank and creating tables) must be writable by uid 1000.

Use the following to use your own uid (and group id)

```
docker build --build-arg UID=$(id -u)  --build-arg GID=$(id -g) -t grew_match:latest .
```


## Run on a treebank

Replace `$MYDIR` with your directory. 

```bash
mkdir $MYDIR/log
mkdir $MYDIR/data
chmod 777 $MYDIR/log $MYDIR/data
cd $MYDIR/data
git clone https://github.com/UniversalDependencies/UD_...
```

add GrewMatch configuration data in two seperate files in `$MYDIR/data/`
(you can add as many treebanks as you wish). Do not forget to set the correct address for the backend-server.

* `config.json` (change only the values `default`, `name` and `corpora.id`):
```json
{
  "backend_server": "http://<back-end-server-name>:8899/",
  "default": "UD_Welsh-CCG@2.11",
  "groups": [
    {
      "id": "UD",
      "name": "UD 2.11",
      "mode": "syntax",
      "style": "left_pane",
      "default": "UD_Welsh@2.11",
      "corpora": [
        {
          "id": "UD_Welsh-CCG@2.11",
          "github": "https://github.com/UniversalDependencies/UD_Welsh-CCG"
        },
        {
          "id": "UD_English-EWT@2.11",
          "github": "https://github.com/UniversalDependencies/UD_English-EWT"
        },
        {
          "id": "UD_French-GSD@2.11",
          "github": "https://github.com/UniversalDependencies/UD_French-GSD"
        },
        {
          "id": "UD_Arabic-PUD@2.11",
          "github": "https://github.com/UniversalDependencies/UD_Arabic-PUD"
        },
        {
          "id": "UD_Arabic-PADT@2.11",
          "github": "https://github.com/UniversalDependencies/UD_Arabic-PADT"
        }
      ]
    },
    {
      "id": "SUD",
      "name": "SUD 2.11",
      "mode": "syntax",
      "style": "left_pane",
      "default": "SUD_French-GSD@2.11",
      "corpora": [
        {
          "id": "SUD_French-GSD@2.11",
          "github": "https://github.com/surfacesyntacticud/SUD_French-GSD"
        }
      ]
    }
  ]
}
```
Use `"style": "dropdown"` instead of `"style": "left_pane"` in order to have
a dropdown menu ant no left-pane.


* `lang.json` (change only the values for `id` and `directory`. For `directory` only change the name of the treebank directory and do not modify the absolute path `/data/`):
```json
{
  "corpora": [
    {
      "id": "UD_Welsh-CCG@2.11",
      "config": "ud",
      "directory": "/data/UD_Welsh-CCG"
    },
    {
      "id": "UD_English-EWT@2.11",
      "config": "ud",
      "directory": "/data/UD_English-EWT"
    },
    {
      "id": "UD_Arabic-PUD@2.11",
      "config": "ud",
      "directory": "/data/UD_Arabic-PUD"
    },
    {
      "id": "UD_Arabic-PADT@2.11",
      "config": "ud",
      "directory": "/data/UD_Arabic-PADT"
    },
    {
      "id": "UD_French-GSD@2.11",
      "config": "ud",
      "directory": "/data/UD_French-GSD"
    },
    {
      "id": "SUD_French-GSD@2.11",
      "config": "ud",
      "directory": "/data/SUD_French-GSD"
    }
  ]
}
```

Start the docker container (replace `$MYDIR` with your directory):
```bash
docker run \
	-p 8000:8000 -p 8899:8899 \
	--hostname localhost \
	--name grewmatch \
	-v $MYDIR/data:/data \
	-v $MYDIR/log:/log \
	-t grew_match
```

Point your browser to `http://<hostname>:8000` to start using grewmatch !

## Use container to transform treebanks in UD format to SUD format and back

see: https://github.com/surfacesyntacticud/

The same image can be used to grew transformations. In order to do so

* clone the SUD/UD converter tools
```
git clone https://github.com/surfacesyntacticud/tools /path/to/surfacesyntacticud-tools
```
* start the container and mount the tools-directory and your treebank data
```bash
docker run \
	-p 8000:8000 -p 8899:8899 \
	--hostname localhost \
	--name grewmatch \
	-v $MYDIR/data:/data \
	-v $MYDIR/log:/log \
        -v /path/to/surfacesyntacticud-tools:/tools \
        -v /path/to/treebanks:/treebanks \
	-t grew_match
```
* open a shell in the container and run `grew transform`
```
docker exec -it grew_match /bin/bash
grew transform -grs  /tools/converter/grs/fr_UD_to_SUD.grs -i /treebanks/UD_French-GSD/fr_gsd-ud-dev.conllu -o /treebanks/UD_French-GSD/fr_gsd-sud-dev.conllu
```

## use with docker-compose

If you have docker-compose installed and prefer it, you can create a configuration file `docker-compose.yml` in your data
directory similar to the following (adapt the left part of the volumes to your needs):

```
version: "3"
services:
    grewmatch:
        image: grewmatch:latest
        ports:
            - 8000:8000
            - 8899:8899
        hostname: localhost
        volumes:
            - ./UD2.11/:/data
            - ./log:/log
            - /path/to/grew/surfacesyntacticud-tools/:/tools
        restart: unless-stopped
```

and start it with:

```
docker-compose up -d
```

