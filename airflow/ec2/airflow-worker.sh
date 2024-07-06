#!/bin/bash
sudo -i -u ubuntu << 'EOF'
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install

mkdir -p /home/ubuntu/airflow
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.11

sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3-apt --reinstall

cd /usr/lib/python3/dist-packages
ls -l | grep apt_pkg
sudo ln -s apt_pkg.cpython-310-x86_64-linux-gnu.so apt_pkg.so

cd /home/ubuntu/airflow
sudo DEBIAN_FRONTEND=noninteractive apt install -y python3.11-venv
python3 -m venv airflow-venv
source airflow-venv/bin/activate

export AIRFLOW_HOME=/home/ubuntu/airflow
AIRFLOW_VERSION=2.7.2
PYTHON_VERSION=3.11
pip install "apache-airflow[celery, amazon, postgres, redis]==${AIRFLOW_VERSION}" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"
mkdir -p ${AIRFLOW_HOME}/dags 
mkdir -p ${AIRFLOW_HOME}/logs

aws s3 cp s3://de-2-1-bucket/airflow/config/airflow.cfg .

CRON_JOB="*/5 * * * * /usr/local/bin/aws s3 sync s3://de-2-1-bucket/airflow/dags /home/ubuntu/airflow/dags --delete"
crontab -l 2>/dev/null; echo "$CRON_JOB" | crontab -
EOF

WORKER_SERVICE_FILE=/etc/systemd/system/airflow-worker.service
FLOWER_SERVICE_FILE=/etc/systemd/system/airflow-flower.service

echo '[Unit]
Description=Airflow worker daemon
After=network.target

[Service]
Environment="PATH=/home/ubuntu/airflow/airflow-venv/bin"
ExecStart=/home/ubuntu/airflow/airflow-venv/bin/airflow celery worker
Restart=on-failure
RestartSec=5s
User=ubuntu

[Install]
WantedBy=multi-user.target' > ${WORKER_SERVICE_FILE}

echo '[Unit]
Description=Airflow flower daemon
After=network.target

[Service]
User=ubuntu
Type=simple
Environment="PATH=/home/ubuntu/airflow/airflow-venv/bin"
WorkingDirectory=/home/ubuntu/airflow
ExecStart=/home/ubuntu/airflow/airflow-venv/bin/airflow celery flower
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target' > ${FLOWER_SERVICE_FILE}

sudo systemctl daemon-reload
sudo systemctl enable airflow-worker.service
sudo systemctl enable airflow-flower.service
sudo systemctl start airflow-worker.service
sudo systemctl start airflow-flower.service