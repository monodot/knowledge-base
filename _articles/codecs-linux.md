---
layout: page
title: Codecs on Linux
---

Support for audio and video codecs on Linux.

## Adding H.264 support to Fedora

This seems to enable **MP4** as a container format:

    sudo dnf install gstreamer1-libav

Then this seems to add **x264enc** as a Codec:

    sudo dnf install gstreamer1-plugins-ugly
