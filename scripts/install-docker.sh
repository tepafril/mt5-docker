wine_executable="${wine_executable:-wine}"
wine_python="${wine_python:-C:\\Program Files (x86)\\Python39-32\\python.exe}"

sudo apt update
sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
docker --version
docker compose version

sudo usermod -aG docker $USER
newgrp docker

mkdir ../mt5
cd ..
cp docker-compose.yaml mt5/docker-compose.yaml

cd mt5
docker compose up -d
cd ..

docker cp tools/start.sh mt5:/Metatrader/start.sh
docker exec -it mt5 bash -c "chmod +x /Metatrader/start.sh"

docker cp python/test-mt5-con.py mt5:/var/www/test-mt5-con.py
docker exec -it mt5 bash -c "chmod +x /var/www/test-mt5-con.py"

docker restart mt5

sleep 30

docker exec -it mt5 bash -c "su abc -c \"$wine_executable \\\"$wine_python\\\" /var/www/test-mt5-con.py\""
docker logs -f mt5