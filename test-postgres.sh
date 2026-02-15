docker cp python/test-postgres-con.py mt5_postgres:test-postgres-con.py
docker exec -it mt5_postgres bash -c "chmod +x test-postgres-con.py"
docker exec -it mt5_postgres bash -c "su abc -c 'wine \"C:\Program Files (x86)\Python39-32\python.exe\" test-postgres-con.py'"