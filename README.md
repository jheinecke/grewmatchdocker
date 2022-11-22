# Dockerfile for http://match.grew.fr

## Build
```
docker build -t grew_match:latest .
```

The container runs using uid 1000. So the directories outside the container where grewmatch writes to (compiling treebank and creating tables) must be writable by uid 1000.

Use the following to use your own uid (and group id)

```
docker build --build-arg UID=$(id -u)  --build-arg UID=$(id -g) -t grew_match:latest .
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
  "default": "UD_Welsh-CCG@master",
  "groups": [
    {
      "id": "cy",
      "name": "UD_Welsh-CCG",
      "mode": "syntax",
      "style": "dropdown",
      "default": "UD_Welsh-CCG@master",
      "corpora": [
        {
          "id": "UD_Welsh-CCG@master"
        }
      ]
    },
    {
      "id": "br",
      "name": "UD_Breton-KEB",
      "mode": "syntax",
      "style": "dropdown",
      "default": "UD_Breton-KEB@master",
      "corpora": [
        {
          "id": "UD_Breton-KEB@master"
        }
      ]
    }
  ]
}
```

* `lang.json` (change only the values for `id` and `directory`. For `directory` only change the name of the treebank directory and do not modify the absolute path `/data/`):
```json
{
  "corpora": [
    {
      "id": "UD_Welsh-CCG@master",
      "config": "ud",
      "directory": "/data/UD_Welsh-CCG"
    },
    {
      "id": "UD_Breton-KEB@master",
      "config": "ud",
      "directory": "/data/UD_Breton-KEB"
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
