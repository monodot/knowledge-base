---
layout: page
title: Webcams on Linux
---

Some trial-and-error notes of trying to use various devices as a webcam on Linux, specifically Fedora.

{% include toc.html %}

## Using an iPhone as a webcam on Fedora (with IPCamera for iOS)

**⚠️ Incomplete instructions - webcam just produces a still image**

Based on: <https://steemit.com/technology/@tech.ninja/tech-quickie-convert-your-ipad-iphone-into-a-good-wireless-webcam-in-linux>:

First install the IPCamera app for iOS. Then:

```
sudo modprobe v4l2loopback devices=1
IPHONE_IP=192.168.1.129
VIDEO_DEVICE=/dev/video2
gst-launch-1.0 souphttpsrc location=http://${IPHONE_IP}:80/live ! jpegdec ! videoconvert ! v4l2sink device=${VIDEO_DEVICE}

```

Except, I just get a still image in Bluejeans, Cheese, etc.....

## Using an iPhone as a webcam on Fedora (with Droidcam for iOS and Linux)

**✅ Tested with Fedora 36.**

Install the Droidcam app for iPhone from the App Store.

The Linux client is open source and on GitHub: <https://github.com/dev47apps/droidcam>

Go to <https://www.dev47apps.com/droidcam/linux/>, download the binary release, extract and run an installer :/ `sudo ./install-client`:

```
$ sudo ./install-client 
[sudo] password for tdonohue: 
Copying files
+ cp uninstall /opt/droidcam-uninstall
+ cp icon2.png /opt/droidcam-icon.png
+ cp droidcam /usr/bin/
+ cp droidcam-cli /usr/bin/
+ set +x
Done
```

Install dependencies for system tray: `sudo dnf install libappindicator-gtk3`. 

Install dependencies, `sudo dnf install kernel-devel kernel-headers gcc make`.

Run another installer :( - `sudo ./install-video`:

```
sudo ./install-video 
[sudo] password for tdonohue: 
Webcam parameters: '640' and '480'
Building v4l2loopback-dc.ko
make: Entering directory '/tmp/droidcam/v4l2loopback'
make -C /lib/modules/5.9.16-200.fc33.x86_64/build M=/tmp/droidcam/v4l2loopback modules
make[1]: Entering directory '/usr/src/kernels/5.9.16-200.fc33.x86_64'
  CC [M]  /tmp/droidcam/v4l2loopback/v4l2loopback-dc.o
  MODPOST /tmp/droidcam/v4l2loopback/Module.symvers
  CC [M]  /tmp/droidcam/v4l2loopback/v4l2loopback-dc.mod.o
  LD [M]  /tmp/droidcam/v4l2loopback/v4l2loopback-dc.ko
make[1]: Leaving directory '/usr/src/kernels/5.9.16-200.fc33.x86_64'
make: Leaving directory '/tmp/droidcam/v4l2loopback'
Copying file
+ cp v4l2loopback/v4l2loopback-dc.ko /lib/modules/5.9.16-200.fc33.x86_64/kernel/drivers/media/video/
+ set +x
Registering webcam device
Running depmod
make: Entering directory '/tmp/droidcam/v4l2loopback'
make -C /lib/modules/5.9.16-200.fc33.x86_64/build M=/tmp/droidcam/v4l2loopback clean
make[1]: Entering directory '/usr/src/kernels/5.9.16-200.fc33.x86_64'
  CLEAN   /tmp/droidcam/v4l2loopback/Module.symvers
make[1]: Leaving directory '/usr/src/kernels/5.9.16-200.fc33.x86_64'
make: Leaving directory '/tmp/droidcam/v4l2loopback'
Adding options v4l2loopback_dc width=640 height=480 to /etc/modprobe.d/droidcam.conf
Adding videodev to /etc/modules-load.d/droidcam.conf
Adding v4l2loopback_dc to /etc/modules-load.d/droidcam.conf
Done
```

Check it's installed a video driver using `lsmod | grep v4l2loopback_dc`:

```
$ lsmod | grep v4l2loopback_dc
v4l2loopback_dc        32768  0
videodev              274432  5 videobuf2_v4l2,v4l2loopback_dc,v4l2loopback,uvcvideo,videobuf2_common
```

Create a shortcut/GNOME applications entry to launch the Droidcam GUI:

```
$ cat << EOF > ~/.local/share/applications/droidcam.desktop 
[Desktop Entry]
Version=1.0
Type=Application
Name=Droidcam
Exec="/usr/bin/droidcam"
Comment=Mobile phone webcam client
Categories=Graphics;Communication
Terminal=false
EOF
```

Now you can start Droidcam from _Applications_, and you should be able to see the phone as another camera source (e.g. in an application like _Cheese_)

### Troubleshooting

_"make: *** /lib/modules/3.3.4-5.fc17.x86_64/build: No such file or directory.  Stop."_:

- The video driver install script runs _make_ which requires access to the Linux source code.
- The directory shown in the error message might exist, but it might be a symlink to a non-existent directory.
- For example, the symlink might point to a version of the kernel which is not installed.
- Make sure you've installed `kernel-devel`, which installs the Linux kernel source code.
- Make sure you've updated `kernel` and `kernel-core` to the same version of `kernel-devel`.

## Using a DSLR as a camera in OBS Studio (and other apps) on Fedora

This describes how to use a DSLR camera (I use a Nikon D7200) as an input camera into applications on Linux, specifically Fedora. This allows you to use the camera as input for applications like OBS Studio, BlueJeans conferencing, etc.

Firstly, install the pre-requisites. You need `v4l2loopback`, which you can either build from source, or install [from the COPR repository](https://copr.fedorainfracloud.org/coprs/sentry/v4l2loopback/) - and run `modprobe`:

```
dnf copr enable sentry/v4l2loopback
sudo dnf install gphoto2 v4l2loopback ffmpeg
```

Then run `modprobe` to enable the `v4l2loopback` module. This allows it to detect the camera and create a device in under `/dev`:

```
sudo modprobe v4l2loopback exclusive_caps=1 max_buffers=2
```

Next, turn on your camera. Run `ls /dev/video*` to see which video device the camera has been assigned to - in this case, mine is `/dev/video2` (because it was created when I turned my camera on):

```
$ ls -al /dev/video*
crw-rw----+ 1 root video 81, 0 Aug 15 11:50 /dev/video0
crw-rw----+ 1 root video 81, 1 Aug 15 11:50 /dev/video1
crw-rw----+ 1 root video 81, 2 Aug 16 13:10 /dev/video2
```

Then run this, replacing `/dev/video2` with your allocated device name you found above:

```
pkill -f gphoto2   
gphoto2 --stdout --capture-movie | ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -threads 0 -f v4l2 /dev/video2
```

The camera's mirror will lock, and you should be able to access in OBS Studio as _Video Capture Device_, or in BlueJeans as an additional Camera input, even in your web browser.

**NB:** for some reason I needed to run `pkill` first, because otherwise it complains _"Could not claim interface 0 (Device or resource busy)"_. This seems to happen because `gphoto2` launches a couple of processes which prevent other processes from capturing the video stream.


