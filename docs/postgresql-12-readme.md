ubuntu 22.04
sudo apt update
sudo apt install curl gpg gnupg2 software-properties-common apt-transport-https lsb-release ca-certificates

curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list


sudo apt update

sudo apt install postgresql-12 postgresql-client-12

systemctl status postgresql@12-main.service


sudo su - postgres

psql -c "alter user postgres with password 'p@ssw0rd'"

sudo nano /etc/postgresql/12/main/postgresql.conf

Uncomment line 59 and change the Listen address to accept connections within your networks.

shared_buffers = 25% of total RAM
work_mem=32mb * number of connections  (32mb * 100 = 3.125gb)
checkpoint_completion_target = 0.9
max_wal_size = 2GB
checkpoint_timeout = 15min
effective_cache_size = 50%-75% of total RAM
autovacuum_naptime = 1min
autovacuum_vacuum_cost_delay = 20ms

max_parallel_workers_per_gather = 2  #CPU BOUND
max_parallel_workers = 4 #CPU BOUND

####
# Listen on all interfaces
listen_addresses = '*'

# Listen on specified private IP address
listen_addresses = '192.168.10.11'


sudo nano /etc/postgresql/12/main/pg_hba.conf

# Accept from anywhere
host all all 0.0.0.0/0 md5

# Accept from trusted subnet
host all all 10.10.10.0/24 md5


sudo systemctl restart postgresql


netstat  -tunelp | grep 5432


root@staging-primary-db:/var/backups# pg_dump -h db-postgresql-sfo2-56908-do-user-1240540-0.b.db.ondigitalocean.com -p 25060 -U doadmin -Fc -b -v -f backup-10-21-24.sql -d  defaultdb

pg_restore -v -h localhost -U postgres -d postgres -j 2 infotrader-backup-10-07-24-staging.sql

RUN VACUUM FULL;





