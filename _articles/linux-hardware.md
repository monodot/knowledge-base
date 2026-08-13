---
layout: page
title: Linux - hardware and displays
---

## Screen

### Managing screen backlight brightness

Discover your backlight device name:

    ls /sys/class/backlight/

Get the current brightness (where `amdgpu_bl1` is your backlight device name):

    cat /sys/class/backlight/amdgpu_bl1/brightness

Get the max brightness:

    cat /sys/class/backlight/amdgpu_bl1/max_brightness

Set brightness to 80%:

    echo 51811 | sudo tee /sys/class/backlight/amdgpu_bl1/brightness   # ~80%

Note: Adaptive Backlight Management (ABM) ("vari-bright") can sometimes dim the panel independently of this value. 
