# Dockerfile for http://match.grew.fr

## Build
```
docker build -t grew:latest .
```

## Run on a treebank

Replace `$MYDIR` with your directory

```
mkdir $MYDIR/log
chmod 777 $MYDIR/log
mkdir $MYDIR/data
cd $MYDIR/data
git clone https://github.com/UniversalDependencies/UD_...
```

add GrewMatch configuration data in two seperate files in `data/`:

* `config.json` (change only the values `default`, `name` and `corpora.id`:
```json
{
  "backend_server": "http://localhost:8899/", 
  "default": "UD_Welsh-CCG@master",
  "groups": [{
    "id": "gold",
    "name": "UD_Welsh",
    "mode": "syntax",
    "style": "dropdown",
    "default": "UD_Welsh-CCG@master",
    "corpora": [{
        "id": "UD_Welsh-CCG@master"
      }
    ]
  }]
}
```

* `lang.json` (change only the values for `id` and `directory`. For `directory` only change the name of the treebank directory and leave `/data/`):
```
{
  "corpora": [
    {
      "id": "UD_Welsh-CCG@master",
      "config": "ud",
      "directory": "/data/UD_Welsh-CCG"
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
	-t grew 
