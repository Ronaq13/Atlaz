
## Build docker image locally and push

```
docker buildx build --platform linux/amd64 -t ghcr.io/ronaq13/atlaz:latest --push .

export KUBECONFIG=~/.kube/staging1-config

kubectl apply -k k8s/overlays/staging-1
kubectl rollout restart deployment/atlaz -n staging-1
kubectl rollout restart deployment/atlaz-sidekiq -n staging-1
kubectl get pods -n staging-1 -w


kubectl exec -it deploy/atlaz -n staging-1 -- bash
```

## External nginx path (gcp-staging-1-partners)

Atlaz runs on k8s NodePort `30013`. Add the block from `deploy/nginx/gcp-staging-1-atlaz.conf`
inside the existing HTTPS `server { ... }` for `gcp-staging-1-partners.thrillo.dev`, then reload nginx.

```bash
# on the staging VM — paste block into /etc/nginx/sites-enabled/staging-partners.conf
sudo nginx -t && sudo systemctl reload nginx
```

Verify:

```bash
curl -s https://gcp-staging-1-partners.thrillo.dev/atlaz/up
curl -s "https://gcp-staging-1-partners.thrillo.dev/atlaz/api/v1/hotels/search?q=dubai&check_in=2026-08-15&sort_by=price_asc"
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