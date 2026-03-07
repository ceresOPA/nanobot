#!/bin/bash

# nanobot-gateway systemd 安装配置脚本

# 配置变量（根据需要修改）
NANOBOT_DIR="/root/nanobot"
CONDA_ENV_PATH="/root/miniconda3/bin/python3"
LOG_DIR="$NANOBOT_DIR/logs"
SERVICE_NAME="nanobot-gateway"

# 读取用户输入
read -p "请输入 nanobot 目录路径 [$NANOBOT_DIR]: " input
NANOBOT_DIR=${input:-$NANOBOT_DIR}

read -p "请输入 conda 环境 python 路径 [$CONDA_ENV_PATH]: " input
CONDA_ENV_PATH=${input:-$CONDA_ENV_PATH}

read -p "请输入日志目录路径 [$LOG_DIR]: " input
LOG_DIR=${input:-$LOG_DIR}

echo ""
echo "配置信息:"
echo "  nanobot 目录: $NANOBOT_DIR"
echo "  python 路径: $CONDA_ENV_PATH"
echo "  日志目录: $LOG_DIR"
echo ""

# 创建日志目录
mkdir -p "$LOG_DIR"

# 创建 service 文件
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Nanobot Gateway Service
After=network.target
StartLimitIntervalSec=60
StartLimitBurst=10

[Service]
Type=simple
User=root
ExecStart=${CONDA_ENV_PATH} -m nanobot gateway
Restart=always
RestartSec=3s
StandardOutput=append:${LOG_DIR}/gateway.log
StandardError=append:${LOG_DIR}/gateway.log
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

echo "已创建 service 文件: $SERVICE_FILE"

# 重新加载 systemd
systemctl daemon-reload

echo ""
echo "安装完成！"
echo ""
echo "使用命令:"
echo "  启动:   sudo systemctl start ${SERVICE_NAME}"
echo "  停止:   sudo systemctl stop ${SERVICE_NAME}"
echo "  状态:   sudo systemctl status ${SERVICE_NAME}"
echo "  日志:   tail -f ${LOG_DIR}/gateway.log"
echo "  开机自启: sudo systemctl enable ${SERVICE_NAME}"
