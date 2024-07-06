#!/bin/bash

# root 유저로 실행됨
cd /home/ubuntu
sudo apt update
sudo apt install -y jq

sudo apt install -y postgresql postgresql-contrib
sudo apt install -y redis-tools

# aws cli 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install

# 파이썬 최신버전 설치
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.11

sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3-apt --reinstall

cd /usr/lib/python3/dist-packages
ls -l | grep apt_pkg
sudo ln -s apt_pkg.cpython-310-x86_64-linux-gnu.so apt_pkg.so

# 파이썬 가상환경 설치
sudo DEBIAN_FRONTEND=noninteractive apt install -y python3.11-venv

# 특정 user에서 원하는 명령어 실행
sudo -i -u ubuntu << 'EOF'
mkdir -p /home/ubuntu/airflow
cd /home/ubuntu/airflow

python3 -m venv airflow-venv
source airflow-venv/bin/activate

export AIRFLOW_HOME=/home/ubuntu/airflow
AIRFLOW_VERSION=2.7.2
PYTHON_VERSION=3.11

pip install "apache-airflow[celery, amazon, postgres, redis]==$AIRFLOW_VERSION" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-$AIRFLOW_VERSION/constraints-$PYTHON_VERSION.txt"
mkdir -p $AIRFLOW_HOME/dags $AIRFLOW_HOME/logs

DB_CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id ${db_secret_id} --query SecretString --output text --region ap-northeast-2)
CELERY_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${redis_secret_id} --query SecretString --output text --region ap-northeast-2)

DB_USERNAME=$(echo $DB_CREDENTIALS | jq -r '.username')
DB_PASSWORD=$(echo $DB_CREDENTIALS | jq -r '.password')

CONFIG_FILE=$AIRFLOW_HOME/airflow.cfg

airflow info

sed -i "s|^sql_alchemy_conn = .*|sql_alchemy_conn = postgresql+psycopg2://$DB_USERNAME:$DB_PASSWORD@${db_host}:5432/airflow|" $CONFIG_FILE
sed -i "s|^broker_url = .*|broker_url = redis://:$CELERY_PASSWORD@${redis_host}:6379/0|" $CONFIG_FILE
sed -i "/^# *result_backend =/c\result_backend = redis://:$CELERY_PASSWORD@${redis_host}:6379/1" $CONFIG_FILE
sed -i "s|^executor = .*|executor = CeleryExecutor|" $CONFIG_FILE
sed -i "s|^x_frame_enabled = .*|x_frame_enabled = False|" $CONFIG_FILE
sed -i "s|^warn_deployment_exposure = .*|warn_deployment_exposure = False|" $CONFIG_FILE
sed -i "s|^catchup_by_default = .*|catchup_by_default = False|" $CONFIG_FILE
sed -i "s|^remote_logging = .*|remote_logging = True|" $CONFIG_FILE
sed -i "s|^remote_log_conn_id = .*|remote_log_conn_id = aws_default|" $CONFIG_FILE
sed -i "s|^remote_base_log_folder = .*|remote_base_log_folder = s3://de-2-1-bucket/airflow/logs|" $CONFIG_FILE
sed -i "s|^default_queue = .*|default_queue = airflow_queue|" $CONFIG_FILE

aws s3 cp airflow.cfg s3://de-2-1-bucket/airflow/config/airflow-test.cfg

CRON_JOB="*/5 * * * * /usr/local/bin/aws s3 sync s3://de-2-1-bucket/airflow/dags /home/ubuntu/airflow/dags --delete"
crontab -l 2>/dev/null; echo "$CRON_JOB" | crontab -

airflow db init

airflow users create \
    --username airflow \
    --firstname jung \
    --lastname hunsoo \
    --role Admin \
    --email airflow@example.com
EOF

# Fetch secrets from AWS Secrets Manager
# DB_CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id ${db_secret_id} --query SecretString --output text --region ap-northeast-2)
# CELERY_CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id ${redis_secret_id} --query SecretString --output text --region ap-northeast-2)

# Parse secrets (assuming JSON format)
# DB_USERNAME=$(echo $DB_CREDENTIALS | jq -r '.username')
# DB_PASSWORD=$(echo $DB_CREDENTIALS | jq -r '.password')
# CELERY_PASSWORD=$(echo $CELERY_CREDENTIALS | jq -r '.password')

# URL-encode passwords
# DB_PASSWORD_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote_plus('$DB_PASSWORD'))")
# CELERY_PASSWORD_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote_plus('$CELERY_PASSWORD'))")

# airflow.cfg 파일 경로
# CONFIG_FILE="$AIRFLOW_HOME/airflow.cfg"

# sed -i "s|^sql_alchemy_conn = .*|sql_alchemy_conn = postgresql+psycopg2://$DB_USERNAME:$DB_PASSWORD@${db_host}:5432/airflow|" $CONFIG_FILE
# sed -i "s|^broker_url = .*|broker_url = redis://$CELERY_PASSWORD@${redis_host}:6379/0|" $CONFIG_FILE
# sed -i "s|^result_backend = .*|result_backend = redis://$CELERY_PASSWORD@${redis_host}:6379/1|" $CONFIG_FILE

# Core 설정 변경
# sed -i "s|^executor = .*|executor = CeleryExecutor|" $CONFIG_FILE

# Webserver 설정 변경
# sed -i "s|^x_frame_enabled = .*|x_frame_enabled = False|" $CONFIG_FILE
# sed -i "s|^warn_deployment_exposure = .*|warn_deployment_exposure = False|" $CONFIG_FILE

# Scheduler 설정 변경
# sed -i "s|^catchup_by_default = .*|catchup_by_default = False|" $CONFIG_FILE

# Logging 설정 변경
# sed -i "s|^remote_logging = .*|remote_logging = True|" $CONFIG_FILE
# sed -i "s|^remote_log_conn_id = .*|remote_log_conn_id = aws_default|" $CONFIG_FILE
# sed -i "s|^remote_base_log_folder = .*|remote_base_log_folder = s3://de-2-1-bucket/airflow/logs|" $CONFIG_FILE

# Operators 설정 변경
# sed -i "s|^default_queue = .*|default_queue = airflow_queue|" $CONFIG_FILE

# export AIRFLOW__CORE__TEST_CONNECTION=enabled
# export AIRFLOW__CORE__LOAD_EXAMPLES=False
# export AIRFLOW__CELERY__WORKER_CONCURRENCY=4
# export AIRFLOW__CELERY__WORKER_AUTOSCALE=4,2

# airflow config list --defaults
# airflow db check
# airflow db init

# aws s3 cp airflow.cfg s3://de-2-1-bucket/airflow/config/airflow-test.cfg 

# github actions -> s3
# CRON_JOB="*/5 * * * * /usr/local/bin/aws s3 sync s3://de-2-1-bucket/airflow/dags /home/ubuntu/airflow/dags --delete"
# crontab -l 2>/dev/null; echo "$CRON_JOB" | crontab -

WEBSERVER_SERVICE_FILE=/etc/systemd/system/airflow-webserver.service
SCHEDULER_SERVICE_FILE=/etc/systemd/system/airflow-scheduler.service

echo '[Unit]
Description=Airflow webserver daemon
After=network.target

[Service]
Environment="PATH=/home/ubuntu/airflow/airflow-venv/bin"
ExecStart=/home/ubuntu/airflow/airflow-venv/bin/airflow webserver -p 8080
Restart=on-failure
RestartSec=10s
User=ubuntu

[Install]
WantedBy=multi-user.target' > $WEBSERVER_SERVICE_FILE

echo '[Unit]
Description=Airflow scheduler daemon
After=network.target

[Service]
User=airflow
Environment="PATH=/home/ubuntu/airflow/airflow-venv/bin"
ExecStart=/home/ubuntu/airflow/airflow-venv/bin/airflow scheduler
Restart=on-failure
RestartSec=5s
User=ubuntu

[Install]
WantedBy=multi-user.target' > $SCHEDULER_SERVICE_FILE

sudo systemctl daemon-reload
sudo systemctl enable airflow-webserver.service
sudo systemctl enable airflow-scheduler.service
sudo systemctl start airflow-webserver.service
sudo systemctl start airflow-scheduler.service