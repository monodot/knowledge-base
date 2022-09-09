---
layout: page
title: Codecs on Linux
---

Support for audio and video codecs on Linux.

## Adding H.264 support to Fedora

Install the RPMFusion repositories first:

    sudo dnf install \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

    sudo dnf install \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

This seems to enable **MP4** as a container format:

    sudo dnf install gstreamer1-libav

Then this seems to add **x264enc** as a Codec:

    sudo dnf install gstreamer1-plugins-ugly

### Notes

gstreamer1-plugins-ugly looks like this:

```
[tdonohue@dougal ~]$ rpm -ql gstreamer1-plugins-ugly
/usr/lib/.build-id
/usr/lib/.build-id/30
/usr/lib/.build-id/30/136abba65dafa1a2925ac33e60c0662dde0073
/usr/lib/.build-id/31
/usr/lib/.build-id/31/a6e35c7c98394813a479336f3cfe5cb6f467c5
/usr/lib/.build-id/4a
/usr/lib/.build-id/4a/1a53b2d137c9a518ea6676119c113d8e94a097
/usr/lib/.build-id/74
/usr/lib/.build-id/74/0ba888f3b7a0f6b41d1ace7a53838dcf4c6f32
/usr/lib/.build-id/74/8d79c5cedb73b8e0144b829cfbde6a20e2953c
/usr/lib/.build-id/c3
/usr/lib/.build-id/c3/576bbb50be460710f7fd370b3e302aa9f8c7aa
/usr/lib/.build-id/ee
/usr/lib/.build-id/ee/40252507f22e33d623b9228495fb7a1b8c6559
/usr/lib64/gstreamer-1.0/libgstamrnb.so
/usr/lib64/gstreamer-1.0/libgstamrwbdec.so
/usr/lib64/gstreamer-1.0/libgstasf.so
/usr/lib64/gstreamer-1.0/libgstdvdlpcmdec.so
/usr/lib64/gstreamer-1.0/libgstdvdsub.so
/usr/lib64/gstreamer-1.0/libgstrealmedia.so
/usr/lib64/gstreamer-1.0/libgstx264.so
/usr/share/doc/gstreamer1-plugins-ugly
/usr/share/doc/gstreamer1-plugins-ugly/AUTHORS
/usr/share/doc/gstreamer1-plugins-ugly/NEWS
/usr/share/doc/gstreamer1-plugins-ugly/README.md
/usr/share/doc/gstreamer1-plugins-ugly/README.static-linking
/usr/share/doc/gstreamer1-plugins-ugly/RELEASE
/usr/share/doc/gstreamer1-plugins-ugly/REQUIREMENTS
/usr/share/gstreamer-1.0
/usr/share/gstreamer-1.0/presets
/usr/share/gstreamer-1.0/presets/GstAmrnbEnc.prs
/usr/share/gstreamer-1.0/presets/GstX264Enc.prs
/usr/share/licenses/gstreamer1-plugins-ugly
/usr/share/licenses/gstreamer1-plugins-ugly/COPYING
```