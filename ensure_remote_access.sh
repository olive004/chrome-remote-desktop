while true

# Make sure correct display number is being patched
sudo chown wadh6511:wadh6511 /opt/google/chrome-remote-desktop/
sudo chown wadh6511:wadh6511 /opt/google/chrome-remote-desktop/chrome-remote-desktop
sed -i 's/FIRST_X_DISPLAY_NUMBER = .*/FIRST_X_DISPLAY_NUMBER = '${DISPLAY#*:}'/' /opt/google/chrome-remote-desktop/chrome-remote-desktop.modified
cp /opt/google/chrome-remote-desktop/chrome-remote-desktop.modified /opt/google/chrome-remote-desktop/chrome-remote-desktop

# Then make sure the service is running
sudo systemctl start chrome-remote-desktop@$USER
# If it's not running make sure it is
# Did not bother implementing this


sleep 300
done
