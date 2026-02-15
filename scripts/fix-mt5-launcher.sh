wine_executable="${wine_executable:-wine}"
wine_python="${wine_python:-C:\\Program Files (x86)\\Python39-32\\python.exe}"

docker cp ../tools/start.sh mt5:/Metatrader/start.sh
docker exec -it mt5 bash -c "chmod +x /Metatrader/start.sh"

docker cp ../python/test-mt5-con.py mt5:/var/www/test-mt5-con.py
docker exec -it mt5 bash -c "chmod +x /var/www/test-mt5-con.py"

docker restart mt5

sleep 30

docker exec -it mt5 bash -c "$wine_executable \"$wine_python\" /var/www/test-mt5-con.py"
docker logs -f mt5