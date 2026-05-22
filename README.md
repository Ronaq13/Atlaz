
## Build docker image locally

```
docker build -t atlaz:local .
```

## Running image locally

Note the env will be staging1 as development and test gems are not installed in image. But you can pass database, redis and typesense local urls. 

```
docker run --rm -it \
  -p 3013:3013 \
  -e RAILS_ENV=staging1 \
  -e DATABASE_URL="postgresql://raounak@host.docker.internal:5432/atlaz_development" \
  -e REDIS_URL="redis://host.docker.internal:6379/0" \
  -e TYPESENSE_HOST="host.docker.internal" \
  -e TYPESENSE_PORT="8108" \
  -e TYPESENSE_PROTOCOL="http" \
  -e RAILS_MASTER_KEY=$(cat config/credentials/staging1.key) \
  atlaz:local
```

## Run typesense locally

```
docker run -p 8108:8108 -v /tmp/typesense-data:/data \
  typesense/typesense:27.0 \
  --data-dir /data --api-key=xyz --enable-cors
```