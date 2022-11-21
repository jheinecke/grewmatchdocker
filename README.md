# Dockerfile for http://match.grew.fr

## Build
```
docker build -t grew:latest .
```

## Run on a treebank

Replace `$MYDIR` with your directory. The container runs using uid 1000. So the directories outside the container where grewmatch writes to (compiling treebank and creating tables) must be writable by uid 1000.

```bash
mkdir $MYDIR/log
mkdir $MYDIR/data
chmod 777 $MYDIR/log $MYDIR/data
cd $MYDIR/data
git clone https://github.com/UniversalDependencies/UD_...
```

add GrewMatch configuration data in two seperate files in `$MYDIR/data/`:
(you can add as many treebanks as you wish)

Do not forget to set the correct address for the backend-server:

* `config.json` (change only the values `default`, `name` and `corpora.id`:
```json
{
  "backend_server": "http://<back-end-server-name>:8899/",
  "default": "UD_Welsh-CCG@master",
  "groups": [
    {
      "id": "gold",
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
      "id": "gold",
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

* `lang.json` (change only the values for `id` and `directory`. For `directory` only change the name of the treebank directory and do not
modify absolute path `/data/`):
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
	-u 1000 \
	-p 8000:8000 -p 8899:8899 \
	--hostname localhost \
	--name grewmatch \
	-v $MYDIR/data:/data \
	-v $MYDIR/log:/log \
	-t grew 
