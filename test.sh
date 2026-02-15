docker cp python/test-mt5-con.py mt5:/var/www/test-mt5-con.py
docker exec -it mt5 bash -c "chmod +x /var/www/test-mt5-con.py"
docker exec -it mt5 bash -c "su abc -c 'wine \"C:\Program Files (x86)\Python39-32\python.exe\" -m pip uninstall numpy -y'"
docker exec -it mt5 bash -c "su abc -c 'wine \"C:\Program Files (x86)\Python39-32\python.exe\" -m pip install \"numpy<2\"'"
docker exec -it mt5 bash -c "su abc -c 'wine \"C:\Program Files (x86)\Python39-32\python.exe\" /var/www/test-mt5-con.py'"