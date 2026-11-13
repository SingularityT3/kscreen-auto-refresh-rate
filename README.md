# Auto Refresh Rate Switcher for Fedora (KDE/Wayland)

This script automatically switches the laptop display refresh rate when AC power
is connected or disconnected.

- On **AC** → sets the maximum refresh rate and turns panel overdrive on  
- On **Battery** → sets the refresh rate and turns panel overdrive off

Overdrive is controlled with `asusctl armoury set panel_overdrive`. If `asusctl`
is not installed, that step is skipped.

## ⚠️ Important information

This script was tested on a **Asus TUF14** laptop laptop with **Fedora 42** with **KDE Plasma 6.4.4** and **Wayland**.

Lower KDE versions, other laptops or similar scripts might get some errors or incompatibilities, please report any issue.

## How it works

A systemd user service runs `set-refresh.sh --watch`, which listens for udev
`power_supply` events and applies the AC or battery mode whenever the power
state changes. The AC adapter is detected automatically.

## Requirements

- `kscreen-doctor` (part of KDE Plasma)  
- `systemd --user` (default on Fedora)
- `udevadm` (part of systemd)
- `asusctl` (optional, for panel overdrive on ASUS laptops)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/<your-username>/auto-refresh-fedora.git
   cd auto-refresh-fedora
   ```

2. Copy the script:
   ```bash
   mkdir -p ~/.local/bin
   cp bin/set-refresh.sh ~/.local/bin/
   chmod +x ~/.local/bin/set-refresh.sh
   ```

3. Install the systemd files:
   ```bash
   mkdir -p ~/.config/systemd/user
   cp systemd/refreshrate.* ~/.config/systemd/user/
   ```

4. Reload and enable:
   ```bash
   systemctl --user daemon-reload
   systemctl --user enable --now refreshrate.service
   ```

5. Test:
   ```bash
   journalctl --user -u refreshrate.service -f
   ```
   Unplug and replug AC power: you should see refresh rate switching.

## Customization

- Edit `OUTPUT`, `MODE_AC`, `MODE_BAT` in `set-refresh.sh` with IDs obtained from:
  ```bash
  kscreen-doctor -o
  ```
- The AC adapter is autodetected (any `Mains` power supply), no configuration needed.

  ---
  
  Default values (`OUTPUT="eDP-1"`, `MODE_AC="1"`, `MODE_BAT="2"`) are just examples.  
  
  Run `kscreen-doctor -o` to get your actual values.


## Uninstallation

```bash
systemctl --user disable --now refreshrate.service
rm ~/.local/bin/set-refresh.sh
rm ~/.config/systemd/user/refreshrate.*
```
