#!/bin/bash

# 📊 Laptop Diagnostics Tool
# Author: YourName
# License: MIT

set -e

# Colors
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
MAGENTA="\e[1;35m"
CYAN="\e[1;36m"
RESET="\e[0m"

print_section() {
  echo -e "\n${MAGENTA}==================== $1 ====================${RESET}"
}

print_table_row() {
  local value="$2"
  if [[ "$value" == *"Not Installed"* || "$value" == *"Not Set"* || "$value" == *"Not Available"* ]]; then
    printf "${CYAN}%-20s${RESET} | ❌ Not Available\n" "$1"
  else
    printf "${CYAN}%-20s${RESET} | %s\n" "$1" "$2"
  fi
}

# Header
echo -e "${GREEN}─────────────────────────────────────────${RESET}"
echo -e "📊 ${BLUE}Dev Diagnostics Report${RESET}  ${CYAN}($(date))${RESET}"
echo -e "${GREEN}─────────────────────────────────────────${RESET}"

# Gather Info
HOST=$(hostname)
OS=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)
KERNEL=$(uname -r)
SHELL_USED=$SHELL
CPU_MODEL=$(lscpu | grep 'Model name' | cut -d ':' -f2 | xargs)
CORES=$(lscpu | grep '^CPU(s):' | awk '{print $2}')
ARCH=$(uname -m)
MEM_TOTAL=$(free -h | awk '/Mem:/ {print $2}')
MEM_USED=$(free -h | awk '/Mem:/ {print $3}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
BATTERY=$(upower -e | grep BAT || true)
BATTERY_PERCENTAGE=$(upower -i $BATTERY 2>/dev/null | grep percentage | awk '{print $2}')
IP_ADDR=$(ip -4 a | grep inet | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
PUBLIC_IP=$(curl -s ifconfig.me)
UPTIME=$(uptime -p)
POWER_ADAPTER=$(upower -i $(upower -e | grep AC) 2>/dev/null | grep online | awk '{print $2}')

# Developer environment
NODE_VERSION=$(node -v 2>/dev/null || echo "Not Installed")
PYTHON_VERSION=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "Not Installed")
GIT_VERSION=$(git --version 2>/dev/null | awk '{print $3}' || echo "Not Installed")
DOCKER_VERSION=$(docker --version 2>/dev/null | awk '{print $3}' || echo "Not Installed")
POSTGRES_VERSION=$(psql --version 2>/dev/null | awk '{print $3}' || echo "Not Installed")
REDIS_VERSION=$(redis-cli --version 2>/dev/null | awk '{print $2}' || echo "Not Installed")
NGINX_VERSION=$(nginx -v 2>&1 | awk -F/ '{print $2}' || echo "Not Installed")
FLUTTER_VERSION=$(flutter --version 2>/dev/null | head -1 || echo "Not Installed")
RUST_VERSION=$(rustc --version 2>/dev/null | awk '{print $2}' || echo "Not Installed")
GO_VERSION=$(go version 2>/dev/null | awk '{print $3}' || echo "Not Installed")
ANDROID_SDK=$(echo "$ANDROID_HOME" || echo "Not Set")

# Display Table
print_section "📦 Summary"
print_table_row "Host" "$HOST"
print_table_row "OS" "$OS"
print_table_row "Kernel" "$KERNEL"
print_table_row "Shell" "$SHELL_USED"
print_table_row "CPU" "$CPU_MODEL"
print_table_row "Cores" "$CORES"
print_table_row "Arch" "$ARCH"
print_table_row "Memory" "$MEM_USED / $MEM_TOTAL"
print_table_row "Disk" "$DISK_USED / $DISK_TOTAL"
print_table_row "Battery" "${BATTERY_PERCENTAGE:-Not Available}"
print_table_row "Private IP" "$IP_ADDR"
print_table_row "Public IP" "$PUBLIC_IP"
print_table_row "Uptime" "$UPTIME"
print_table_row "Power Adapter" "${POWER_ADAPTER:-Not Available}"

print_section "🛠️ Dev Environment"
print_table_row "Node.js" "$NODE_VERSION"
print_table_row "Python" "$PYTHON_VERSION"
print_table_row "Git" "$GIT_VERSION"
print_table_row "Docker" "$DOCKER_VERSION"
print_table_row "PostgreSQL" "$POSTGRES_VERSION"
print_table_row "Redis" "$REDIS_VERSION"
print_table_row "NGINX" "$NGINX_VERSION"
print_table_row "Flutter" "$FLUTTER_VERSION"
print_table_row "Rust" "$RUST_VERSION"
print_table_row "Go" "$GO_VERSION"
print_table_row "Android SDK" "$ANDROID_SDK"

# 📒 Ask to save report
print_section "📒 Export Report"
echo -n "Do you want to export the diagnostics report (txt/json/md/html)? [n/txt/json/md/html]: "
read -r EXPORT_TYPE

if [[ "$EXPORT_TYPE" != "n" && "$EXPORT_TYPE" != "N" ]]; then
  DOWNLOADS_DIR="$HOME/Downloads"
  TIMESTAMP=$(date +%F-%H%M%S)
  case $EXPORT_TYPE in
    txt)
      REPORT_FILE="$DOWNLOADS_DIR/diagnostics-$TIMESTAMP.txt"
      ;;
    json)
      REPORT_FILE="$DOWNLOADS_DIR/diagnostics-$TIMESTAMP.json"
      ;;
    md)
      REPORT_FILE="$DOWNLOADS_DIR/diagnostics-$TIMESTAMP.md"
      ;;
    html)
      REPORT_FILE="$DOWNLOADS_DIR/diagnostics-$TIMESTAMP.html"
      ;;
    *)
      echo "Invalid option. Report not saved."
      exit 0
      ;;
  esac

  echo "Saving report to $REPORT_FILE"

  case $EXPORT_TYPE in
    txt|md)
      {
        echo "Dev Diagnostics Report - $(date)"
        echo "========================================"
        print_table_row "Host" "$HOST"
        print_table_row "OS" "$OS"
        print_table_row "Kernel" "$KERNEL"
        print_table_row "Shell" "$SHELL_USED"
        print_table_row "CPU" "$CPU_MODEL"
        print_table_row "Cores" "$CORES"
        print_table_row "Arch" "$ARCH"
        print_table_row "Memory" "$MEM_USED / $MEM_TOTAL"
        print_table_row "Disk" "$DISK_USED / $DISK_TOTAL"
        print_table_row "Battery" "${BATTERY_PERCENTAGE:-Not Available}"
        print_table_row "Private IP" "$IP_ADDR"
        print_table_row "Public IP" "$PUBLIC_IP"
        print_table_row "Uptime" "$UPTIME"
        print_table_row "Power Adapter" "${POWER_ADAPTER:-Not Available}"
        echo ""
        echo "Developer Environment:"
        print_table_row "Node.js" "$NODE_VERSION"
        print_table_row "Python" "$PYTHON_VERSION"
        print_table_row "Git" "$GIT_VERSION"
        print_table_row "Docker" "$DOCKER_VERSION"
        print_table_row "PostgreSQL" "$POSTGRES_VERSION"
        print_table_row "Redis" "$REDIS_VERSION"
        print_table_row "NGINX" "$NGINX_VERSION"
        print_table_row "Flutter" "$FLUTTER_VERSION"
        print_table_row "Rust" "$RUST_VERSION"
        print_table_row "Go" "$GO_VERSION"
        print_table_row "Android SDK" "$ANDROID_SDK"
      } > "$REPORT_FILE"
      ;;
    json)
      jq -n \
        --arg host "$HOST" \
        --arg os "$OS" \
        --arg kernel "$KERNEL" \
        --arg shell "$SHELL_USED" \
        --arg cpu "$CPU_MODEL" \
        --arg cores "$CORES" \
        --arg arch "$ARCH" \
        --arg mem_used "$MEM_USED" \
        --arg mem_total "$MEM_TOTAL" \
        --arg disk_used "$DISK_USED" \
        --arg disk_total "$DISK_TOTAL" \
        --arg battery "${BATTERY_PERCENTAGE:-Not Available}" \
        --arg ip_private "$IP_ADDR" \
        --arg ip_public "$PUBLIC_IP" \
        --arg uptime "$UPTIME" \
        --arg power_adapter "${POWER_ADAPTER:-Not Available}" \
        --arg node "$NODE_VERSION" \
        --arg python "$PYTHON_VERSION" \
        --arg git "$GIT_VERSION" \
        --arg docker "$DOCKER_VERSION" \
        --arg postgres "$POSTGRES_VERSION" \
        --arg redis "$REDIS_VERSION" \
        --arg nginx "$NGINX_VERSION" \
        --arg flutter "$FLUTTER_VERSION" \
        --arg rust "$RUST_VERSION" \
        --arg go "$GO_VERSION" \
        --arg android "$ANDROID_SDK" \
        '{
          timestamp: now | todate,
          system: {
            host: $host,
            os: $os,
            kernel: $kernel,
            shell: $shell,
            cpu: $cpu,
            cores: $cores,
            arch: $arch,
            memory: { used: $mem_used, total: $mem_total },
            disk: { used: $disk_used, total: $disk_total },
            battery: $battery,
            ip: { private: $ip_private, public: $ip_public },
            uptime: $uptime,
            power_adapter: $power_adapter
          },
          dev_environment: {
            node: $node,
            python: $python,
            git: $git,
            docker: $docker,
            postgres: $postgres,
            redis: $redis,
            nginx: $nginx,
            flutter: $flutter,
            rust: $rust,
            go: $go,
            android_sdk: $android
          }
        }' > "$REPORT_FILE"
      ;;
    html)
      echo "<html><head><title>Dev Diagnostics</title></head><body><h1>Dev Diagnostics Report</h1><pre>" > "$REPORT_FILE"
      bash "$0" | sed 's/\x1b\[[0-9;]*m//g' >> "$REPORT_FILE"
      echo "</pre></body></html>" >> "$REPORT_FILE"
      ;;
  esac

  print_table_row "📃 Report saved at" "$REPORT_FILE"
else
  print_table_row "❌ Report" "was not saved."
fi

exit 0
