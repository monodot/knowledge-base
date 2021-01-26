---
layout: page
title: ffmpeg
---

## Cookbook

Convert MKV to MP4 and trim the first 7 seconds:

    ffmpeg -ss 7 -i Screencast.mkv -c copy example.mp4

