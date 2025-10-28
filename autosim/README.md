# Autosim - Automatic SIM Slot Switcher

Autosim is a persistent service that monitors SIM card slots and automatically switches between them when a SIM is inserted or removed.

## Features

- Monitors both SIM slots (Slot 1 and Slot 2)
- Automatically switches to a slot when a SIM is detected
- Handles SIM removal and insertion events
- Runs as a systemd service for persistence
- Debug logging for troubleshooting

## Installation

### Prerequisites

- SSH access to the modem (default: root@192.168.225.1)
- The modem must be accessible via network

### Quick Install

From the toolkit directory, run:

```bash
./install_autosim.sh
```

The script will:
1. Ask if you want to install (new) or update (existing)
2. Copy necessary files to the modem
3. Install the service
4. Enable and start the service
5. Create systemd symlinks for persistence

### Custom Modem IP/User

If your modem has a different IP or username:

```bash
MODEM_IP=192.168.1.100 MODEM_USER=admin ./install_autosim.sh
```

## Usage

### Check Service Status

```bash
ssh root@192.168.225.1 'systemctl status autosim.service'
```

### View Logs

View real-time logs:
```bash
ssh root@192.168.225.1 'journalctl -u autosim.service -f'
```

View recent logs:
```bash
ssh root@192.168.225.1 'journalctl -u autosim.service -n 50'
```

### Start/Stop Service

Start:
```bash
ssh root@192.168.225.1 'systemctl start autosim.service'
```

Stop:
```bash
ssh root@192.168.225.1 'systemctl stop autosim.service'
```

Restart:
```bash
ssh root@192.168.225.1 'systemctl restart autosim.service'
```

### Enable/Disable Auto-Start

Enable (start on boot):
```bash
ssh root@192.168.225.1 'systemctl enable autosim.service'
```

Disable:
```bash
ssh root@192.168.225.1 'systemctl disable autosim.service'
```

## Manual Installation

If you need to install manually:

1. Copy files to modem:
```bash
scp autosim/autosim root@192.168.225.1:/tmp/autosim.sh
scp autosim/autosim.service root@192.168.225.1:/tmp/autosim.service
scp simpleupdates/scripts/update_autosim.sh root@192.168.225.1:/tmp/
```

2. SSH into the modem:
```bash
ssh root@192.168.225.1
```

3. Install:
```bash
chmod +x /tmp/update_autosim.sh
/tmp/update_autosim.sh install
```

## Updating

To update an existing installation:

```bash
./install_autosim.sh
```

Choose option `2` (Update autosim)

Or manually:
```bash
ssh root@192.168.225.1
/tmp/update_autosim.sh update
```

## How It Works

1. The service checks both SIM slots every 10 seconds
2. If a SIM is detected in a slot, it switches to that slot
3. After switching, it waits 3 seconds before checking again
4. The service runs continuously in the background
5. Systemd ensures the service starts on boot and restarts if it crashes

## Service Persistence

The service is persisted using systemd symlinks:
- Service file: `/lib/systemd/system/autosim.service`
- Symlink: `/lib/systemd/system/multi-user.target.wants/autosim.service`

This ensures the service:
- Starts automatically on boot
- Restarts if it crashes
- Runs in multi-user mode

## Troubleshooting

### Service not starting

Check status:
```bash
ssh root@192.168.225.1 'systemctl status autosim.service'
```

Check logs:
```bash
ssh root@192.168.225.1 'journalctl -u autosim.service -n 100'
```

### Script not executable

```bash
ssh root@192.168.225.1 'chmod +x /sbin/autosim'
```

### Service file issues

Re-install the service:
```bash
./install_autosim.sh
```

Choose option `2` (Update)

## Files

- `/sbin/autosim` - Main autosim script
- `/lib/systemd/system/autosim.service` - Systemd service file
- `/lib/systemd/system/multi-user.target.wants/autosim.service` - Service symlink

## Configuration

### Debug Mode

Debug logging is enabled by default. To disable, edit `/sbin/autosim`:
```bash
DEBUG=0
```

### Check Interval

To change how often slots are checked, edit `/sbin/autosim`:
```bash
LOOP_SLEEP=10  # Check every 10 seconds
```

### Slot Delay

To change delay after switching slots, edit `/sbin/autosim`:
```bash
SLOT_SLEEP=3  # Wait 3 seconds after switch
```

## Uninstallation

```bash
ssh root@192.168.225.1
systemctl stop autosim.service
systemctl disable autosim.service
mount -o remount,rw /
rm /sbin/autosim
rm /lib/systemd/system/autosim.service
rm /lib/systemd/system/multi-user.target.wants/autosim.service
systemctl daemon-reload
mount -o remount,ro /
```
