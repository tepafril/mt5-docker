docker cp python/test-postgres-con.py mt5:/var/www/test-postgres-con.py
docker exec -it mt5 bash -c "chmod +x /var/www/test-postgres-con.py"
docker exec -it mt5 bash -c "su abc -c 'wine \"C:\Program Files (x86)\Python39-32\python.exe\" /var/www/test-postgres-con.py'"sh