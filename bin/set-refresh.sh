#!/bin/bash
OUTPUT="eDP-1" # Output name (you can find it using `kscreen-doctor -o`)
MODE_AC="1"    # ID for mode when on AC power
MODE_BAT="2"   # ID for mode when on battery power

# Autodetect AC state: any power supply of type Mains (ADP0, ADP1, AC, ACAD...)
# that reports online=1. USB-C sources are type USB, so they are ignored.
on_ac() {
    local d
    for d in /sys/class/power_supply/*; do
        [ "$(cat "$d/type" 2>/dev/null)" = "Mains" ] || continue
        [ "$(cat "$d/online" 2>/dev/null)" = "1" ] && return 0
    done
    return 1
}

# Panel overdrive via asusctl: on when plugged in, off on battery.
# Skipped silently if asusctl is missing or the attribute is unsupported.
set_overdrive() {
    command -v asusctl >/dev/null 2>&1 || return 0
    asusctl armoury set panel_overdrive "$1" >/dev/null 2>&1 || true
}

apply() {
    if on_ac; then
        kscreen-doctor output.$OUTPUT.mode.$MODE_AC
        set_overdrive 1
    else
        kscreen-doctor output.$OUTPUT.mode.$MODE_BAT
        set_overdrive 0
    fi
}

apply
# With --watch, re-apply whenever a power_supply udev event arrives.
if [ "$1" = "--watch" ]; then
    udevadm monitor --udev --subsystem-match=power_supply |
    while read -r _; do
        sleep 1   # let events settle and coalesce
        read -r -t 0.1 -N 100000 _ 2>/dev/null
        apply
    done
fi
