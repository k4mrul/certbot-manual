
# certbot-manual

### Step 1
```
apply main-deployment.yaml first in main/sg cluster ONLY
```


Now within the ssl-generation-* pod, execute
```
certbot certonly \
  --manual \
  --preferred-challenges http \
  --manual-auth-hook ./certbot.sh \
  --manual-cleanup-hook ./cleanup-host.sh \
  --agree-tos \
  --register-unsafely-without-email \
  --staging \
  -d lb.sre.ovh

```
