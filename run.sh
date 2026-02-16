GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}[1/7] Creating mt5 directory...${NC}"
mkdir -p mt5

echo -e "${GREEN}[2/7] Copying docker-compose into mt5...${NC}"
cp docker-compose.yaml mt5/docker-compose.yaml

echo -e "${GREEN}[3/7] Starting containers in detached mode...${NC}"
cd mt5

if docker ps -q -f "name=^/mt5$" -f "status=running" | grep -q .; then
  echo -e "  ${GREEN}Container mt5 is already running.${NC}"
else
  docker compose build --no-cache
  docker compose up -d
  docker logs -f mt5
fi

# echo -e "${GREEN}Waiting for container (30s countdown)...${NC}"
# for i in $(seq 120 -1 1); do
#   echo -ne "\r  ${GREEN}$i${NC} seconds remaining  "
#   sleep 1
# done
# echo -ne "\r                              \r"

cd ..

echo -e "${GREEN}[4/7] Copying start script into container and making it executable...${NC}"
docker cp tools/start.sh mt5:/Metatrader/start.sh
docker exec -it mt5 bash -c "chmod +x /Metatrader/start.sh"

echo -e "${GREEN}[5/7] Restarting container to run the new start script...${NC}"
docker restart mt5

echo -e "${GREEN}[6/7] Installing numpy<2 and psycopg2-binary for MetaTrader5/PostgreSQL (Wine Python)...${NC}"
docker exec -it mt5 bash -c "su abc -c 'wine \"C:\Program Files (x86)\Python39-32\python.exe\" -m pip uninstall numpy -y'"
docker exec -it mt5 bash -c "su abc -c 'wine \"C:\Program Files (x86)\Python39-32\python.exe\" -m pip install \"numpy<2\" psycopg2-binary'"

echo -e "${GREEN}[7/7] Restarting container after pip changes...${NC}"
docker restart mt5

echo -e "${GREEN}Streaming container logs (Ctrl+C to stop)...${NC}"
docker logs -f mt5