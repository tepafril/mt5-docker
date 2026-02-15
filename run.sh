# Create mt5 directory if it does not exist
mkdir -p mt5
# Copy docker-compose into mt5 so we run compose from there
cp docker-compose.yaml mt5/docker-compose.yaml

# Enter mt5 and start containers in detached mode
cd mt5
docker compose up -d
cd ..

# Copy start script into container and make it executable
docker cp tools/start.sh mt5:/Metatrader/start.sh
docker exec -it mt5 bash -c "chmod +x /Metatrader/start.sh"

# Restart container so it runs the new start script
docker restart mt5

# In container: uninstall default numpy, then install numpy<2 for MetaTrader5 compatibility
docker exec -it mt5 bash -c "su abc -c 'wine \"C:\Program Files (x86)\Python39-32\python.exe\" -m pip uninstall numpy -y'"
docker exec -it mt5 bash -c "su abc -c 'wine \"C:\Program Files (x86)\Python39-32\python.exe\" -m pip install \"numpy<2\"'"

# Restart again after pip changes
docker restart mt5

# Stream container logs (Ctrl+C to stop)
docker logs -f mt5