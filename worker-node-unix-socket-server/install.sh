
chmod +x entrypoint-server
sudo mv entrypoint-server /usr/local/bin/
sudo mkdir /var/lib/entrypoint
sudo mv get-entrypoint-v2.sh /var/lib/entrypoint/

cat <<EOF | sudo tee /etc/systemd/system/entrypoint.service
[Unit]
Description=Entrypoint socket server to retrieve image's entrypoint commands

[Service]
ExecStart=/usr/local/bin/entrypoint-server
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable entrypoint
sudo systemctl start entrypoint