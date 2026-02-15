mkdir -p mt5
cp docker-compose.yaml mt5/docker-compose.yaml

cd mt5
docker compose up -d
cd ..

docker cp tools/start.sh mt5:/Metatrader/start.sh
docker exec -it mt5 bash -c "chmod +x /Metatrader/start.sh"

docker restart mt5

# docker exec -it mt5 bash -c "su abc -c \"$wine_executable \\\"$wine_python\\\" /var/www/test-mt5-con.py\""
docker logs -f mt5