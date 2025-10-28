#!/bin/bash

# Autosim Installation Script for Quectel RGMII Toolkit
# This script deploys autosim to the modem

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTOSIM_SCRIPT="$SCRIPT_DIR/autosim/autosim"
AUTOSIM_SERVICE="$SCRIPT_DIR/autosim/autosim.service"
UPDATE_SCRIPT="$SCRIPT_DIR/simpleupdates/scripts/update_autosim.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Autosim Installation Script ===${NC}"
echo ""

# Check if required files exist
if [ ! -f "$AUTOSIM_SCRIPT" ]; then
    echo -e "${RED}Error: Autosim script not found at $AUTOSIM_SCRIPT${NC}"
    exit 1
fi

if [ ! -f "$AUTOSIM_SERVICE" ]; then
    echo -e "${RED}Error: Autosim service file not found at $AUTOSIM_SERVICE${NC}"
    exit 1
fi

if [ ! -f "$UPDATE_SCRIPT" ]; then
    echo -e "${RED}Error: Update script not found at $UPDATE_SCRIPT${NC}"
    exit 1
fi

# Check for SSH connection details
if [ -z "$MODEM_IP" ]; then
    MODEM_IP="192.168.225.1"
    echo -e "${YELLOW}Using default modem IP: $MODEM_IP${NC}"
fi

if [ -z "$MODEM_USER" ]; then
    MODEM_USER="root"
    echo -e "${YELLOW}Using default user: $MODEM_USER${NC}"
fi

echo ""
echo "Modem IP: $MODEM_IP"
echo "User: $MODEM_USER"
echo ""

# Ask for action
echo "Select action:"
echo "  1) Install autosim (new installation)"
echo "  2) Update autosim (update existing installation)"
echo ""
read -p "Enter choice [1-2]: " choice

case $choice in
    1)
        ACTION="install"
        echo -e "${GREEN}Installing autosim...${NC}"
        ;;
    2)
        ACTION="update"
        echo -e "${GREEN}Updating autosim...${NC}"
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo "Step 1: Copying autosim script to modem..."
scp "$AUTOSIM_SCRIPT" "${MODEM_USER}@${MODEM_IP}:/tmp/autosim.sh"
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to copy autosim script${NC}"
    exit 1
fi

echo "Step 2: Copying autosim service to modem..."
scp "$AUTOSIM_SERVICE" "${MODEM_USER}@${MODEM_IP}:/tmp/autosim.service"
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to copy autosim service${NC}"
    exit 1
fi

echo "Step 3: Copying update script to modem..."
scp "$UPDATE_SCRIPT" "${MODEM_USER}@${MODEM_IP}:/tmp/update_autosim.sh"
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to copy update script${NC}"
    exit 1
fi

echo "Step 4: Making update script executable..."
ssh "${MODEM_USER}@${MODEM_IP}" "chmod +x /tmp/update_autosim.sh"

echo "Step 5: Running $ACTION on modem..."
ssh "${MODEM_USER}@${MODEM_IP}" "/tmp/update_autosim.sh $ACTION"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}=== Autosim $ACTION completed successfully! ===${NC}"
    echo ""
    echo "You can check the service status with:"
    echo "  ssh ${MODEM_USER}@${MODEM_IP} 'systemctl status autosim.service'"
    echo ""
    echo "To view logs:"
    echo "  ssh ${MODEM_USER}@${MODEM_IP} 'journalctl -u autosim.service -f'"
else
    echo -e "${RED}Autosim $ACTION failed!${NC}"
    exit 1
fi

# Cleanup
echo "Cleaning up temporary files on modem..."
ssh "${MODEM_USER}@${MODEM_IP}" "rm -f /tmp/autosim.sh /tmp/autosim.service /tmp/update_autosim.sh"

echo -e "${GREEN}Done!${NC}"
