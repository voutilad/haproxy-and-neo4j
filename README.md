# haproxy-and-neo4j
Example config and helper script for front-ending a Neo4j instance with HAProxy

Example /etc/crontab entry:
```
0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && /usr/local/bin/letsencrypt.sh renew c360.sisu.io
```
