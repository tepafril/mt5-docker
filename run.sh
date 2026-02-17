GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}[1/8] Creating mt5 directory...${NC}"
mkdir -p mt5

echo -e "${GREEN}[2/8] Copying docker-compose into mt5...${NC}"
cp docker-compose.yaml mt5/docker-compose.yaml

echo -e "${GREEN}[3/8] Starting containers in detached mode...${NC}"
cd mt5

if docker ps -q -f "name=^/mt5$" -f "status=running" | grep -q .; then
  echo -e "  ${GREEN}Container mt5 is already running.${NC}"
else
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

echo -e "${GREEN}[4/8] Copying start script into MT5 container and making it executable...${NC}"
docker cp tools/start.sh mt5:/Metatrader/start.sh
docker exec -it mt5 bash -c "chmod +x /Metatrader/start.sh"

echo -e "${GREEN}[5/8] Restarting container to run the new start script...${NC}"
docker restart mt5

echo -e "${GREEN}[6/8] Unnstalling numpy2.*...${NC}"
docker exec -it mt5 bash -c "su abc -c 'wine \"C:\Program Files (x86)\Python39-32\python.exe\" -m pip uninstall numpy -y'"

echo -e "${GREEN}[7/8] Installing numpy<2 and psycopg2-binary for PostgreSQL (Wine Python)...${NC}"
docker exec -it postgres bash -c "su abc -c 'wine \"C:\Program Files (x86)\Python39-32\python.exe\" -m pip install \"numpy<2\" psycopg2-binary'"

echo -e "${GREEN}[8/8] Restarting container after pip changes...${NC}"
docker restart mt5

echo -e "${GREEN}Streaming container logs (Ctrl+C to stop)...${NC}"
docker logs -f mt5