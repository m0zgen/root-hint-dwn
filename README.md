# Root Hint File for DNS Download

This is a root hint file for DNS download. It is generated from the IANA root zone database.

Root files information you can find on [IANA website](https://www.iana.org/domains/root/files).

Downloaded file is located in `root.hints` file in `downloads` directory.

* URL: https://www.internic.net/domain/named.cache

## Cron job for download

```bash
0 4 1 * * /path/to/root-hint-dwn/run.sh -c "telegram_notify" -t "/path/to/dest/root.hints" > /dev/null 2>&1
```