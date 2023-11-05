# Root Hint File for DNS Download

This is a root hint file for DNS download. It is generated from the IANA root zone database.

Root files information you can find on [IANA website](https://www.iana.org/domains/root/files).

Downloaded file is located in `root.hints` file in `downloads` directory.

* URL: https://www.internic.net/domain/named.cache

# Features

Before download file, script comparing local and remote file sizes, if sizes differents, file will download and then will run defined command.

## Cron job for download

```bash
0 4 1 * * /path/to/root-hint-dwn/run.sh -c "telegram_notify" -t "/path/to/dest/root.hints" > /dev/null 2>&1
```

Or for `cron.d`:
```bash
30 1 1,15 * * root /path/to/update_root_hints.sh '/usr/bin/systemctl restart service' 2>&1
```

Enjoy.