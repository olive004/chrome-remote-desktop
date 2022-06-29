# Chrome Remote Desktop patches

After 2 days of pain... here are the patches that made my chrome remote desktop work in the same session of my Ubuntu 20.10. Assuming you've installed the debian current chrome remote desktop file and are still failing to get remote access with a PIN to work reliably, I hope these fixes help you. 

The most important / bulk of the changes are in the `/opt/google/chrome-remote-desktop/chrome-remote-desktop.modified` file, which is then copied into the `/opt/google/chrome-remote-desktop/chrome-remote-desktop` file.

The directories here are set up to mirror the root ('/') folder of an Ubuntu or broadly linux distro system. The files in them are the ones I use for running my chrome remote desktop. You should be able to copy them into your system as is (of course keep the originals of your own versions of these files).

## Instructions
1. Have the `ensure_remote_access.sh` script running in the background in case something breaks. As this requires superuser privileges due to the `sudo chown` command, this command was added to a sudoers config, but if you are uncomfortable with this adjustment, everything should run smoothly without these.
	- Non-essential files: `ensure_remote_access.sh` and `/etc/sudoers.d/remote_desktop`
2. Make a copy of your original files (eg. copy `/opt/google/chrome-remote-desktop/chrome-remote-desktop` and save it for example as `/opt/google/chrome-remote-desktop/chrome-remote-desktop.orig`)
2. Copy the files from this repository onto your system, mirroring the directories they are listed in as if you're starting from the root directory.


## Known bugs

- Starting up before login ([source](https://askubuntu.com/questions/1292318/chrome-remote-desktop-remote-access-into-curently-opened-sesion))
    - modify `/etc/init.d/chrome-remote-desktop` with an `exit 0` at the beginning - can get into a login loop bug otherwise
    - add to startup applications - did not do and was fine
- Display manager unsupported - gdm
    - Comments: That said, I at one point switched back to gdm after everything was working and the remote access still worked, except that the sames session was not being used, so some applications were split between remote and local screens with no way to access them from one to the other. - fixed
    - Switch to lightdm (recommended but you can use whatever else you want except gdm)
        - You can check the `/opt/google/chrome-remote-desktop/chrome-remote-desktop` file - there’s a function that checks whether the display manager is supported and returns false for gdm
- Include a Windows desktop manager manually
    - Have to include a custom `exec` command: `sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/cinnamon-session-cinnamon2d" > /etc/chrome-remote-desktop-session'` ([source](https://cloud.google.com/architecture/chrome-desktop-remote-on-compute-engine#cinnamon))
- Display number defined incorrectly
    - I recommend that you have a script running in the background that automatically corrects this, as the display number actually changes for me from time to time (depending on display manager, updates, etc.)
    - Create modified `/opt/google/chrome-remote-desktop/chrome-remote-desktop.modified` from `/opt/google/chrome-remote-desktop/chrome-remote-desktop`
    
    ```jsx
    sudo sed -i 's/FIRST_X_DISPLAY_NUMBER = .*/FIRST_X_DISPLAY_NUMBER = '${DISPLAY#*:}'/' /opt/google/chrome-remote-desktop/chrome-remote-desktop.modified
    sudo cp /opt/google/chrome-remote-desktop/chrome-remote-desktop.modified /opt/google/chrome-remote-desktop/chrome-remote-desktop
    ```
    
- User not always automatically added to `chrome-remote-desktop` group - fixed
    - Just run `sudo /opt/google/chrome-remote-desktop/chrome-remote-desktop --add-user-as-root $USER`

## Sanity checks

If you are still getting the error “An unknown error has occurred.”

- Check if the service is active: `sudo systemctl list-units -all | grep chrome` or via `sudo systemctl status chrome-remote-desktop@$USER`
    - Output useful from `service chrome-remote-desktop@$USER restart`
    - Can also try to see logs from `journalctl -fexu chrome-remote-desktop@wadh6511.service`
- Check if you’re in the group `chrome-remote-desktop`: various ways to do this but can check `sudo cat /etc/group` to see if `chrome-remote-desktop` is in it and has the `$USER` in the same line
- If you previously managed to connect to the remote access but are having problems now with activating the remote, check the local computer that you connected from and see if the Chrome Remote Desktop entry for your remote device has any clues - mine gave me the error at one point that “X server crashed or failed to start”
