#!/bin/bash
AUTOSIM_SCRIPT="/sbin/autosim"
AUTOSIM_SERVICE="/lib/systemd/system/autosim.service"
SERVICE_LINK="/lib/systemd/system/multi-user.target.wants/autosim.service"

# Function to remount file system as read-write
remount_rw() {
	mount -o remount,rw /
}

# Function to remount file system as read-only
remount_ro() {
	mount -o remount,ro /
}

# Install autosim script
install_autosim_script() {
	echo "Installing autosim script..."
	remount_rw
	cp /tmp/autosim.sh $AUTOSIM_SCRIPT
	chmod +x $AUTOSIM_SCRIPT
	remount_ro
	echo "Autosim script installed to $AUTOSIM_SCRIPT"
	rm /tmp/autosim.sh 2>/dev/null
}

# Install autosim service
install_autosim_service() {
	echo "Installing autosim service..."
	remount_rw
	
	# Copy service file
	cp /tmp/autosim.service $AUTOSIM_SERVICE
	chmod 644 $AUTOSIM_SERVICE
	
	# Create symlink to enable service
	ln -sf $AUTOSIM_SERVICE $SERVICE_LINK
	
	remount_ro
	echo "Autosim service installed to $AUTOSIM_SERVICE"
	rm /tmp/autosim.service 2>/dev/null
}

# Reload systemd and restart service
reload_and_restart_service() {
	echo "Reloading systemd daemon..."
	systemctl daemon-reload
	
	echo "Enabling and restarting autosim service..."
	systemctl enable autosim.service
	systemctl restart autosim.service
	
	# Show service status
	systemctl status autosim.service --no-pager
}

# Main installation function
install_autosim() {
	echo "=== Installing Autosim ==="
	
	# Check if files exist in /tmp
	if [ ! -f /tmp/autosim.sh ]; then
		echo "Error: /tmp/autosim.sh not found!"
		return 1
	fi
	
	if [ ! -f /tmp/autosim.service ]; then
		echo "Error: /tmp/autosim.service not found!"
		return 1
	fi
	
	# Install script
	install_autosim_script
	
	# Install service
	install_autosim_service
	
	# Reload and restart
	reload_and_restart_service
	
	echo "=== Autosim installation complete ==="
}

# Update function (same as install but stops service first)
update_autosim() {
	echo "=== Updating Autosim ==="
	
	# Stop service if running
	if systemctl is-active --quiet autosim.service; then
		echo "Stopping autosim service..."
		systemctl stop autosim.service
	fi
	
	# Run installation
	install_autosim
}

# Check command line argument
case "$1" in
	install)
		install_autosim
		;;
	update)
		update_autosim
		;;
	*)
		echo "Usage: $0 {install|update}"
		echo "  install - Install autosim from /tmp/autosim.sh and /tmp/autosim.service"
		echo "  update  - Update existing autosim installation"
		exit 1
		;;
esac