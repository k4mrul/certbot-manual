# certbot-manual

```
sudo certbot certonly --manual --preferred-challenges http  --manual-auth-hook ./certbot.sh --manual-cleanup-hook ./cleanup-host.sh -d lb4.sre.ovh
```
