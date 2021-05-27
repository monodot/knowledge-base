---
layout: page
title: Video processing in Linux (ffmpeg, convert, etc.)
---

## Cookbook

### Convert MKV to MP4 and trim the first 7 seconds

```
ffmpeg -ss 7 -i Screencast.mkv -c copy example.mp4
```

### Convert an MPEG TS to a GIF (via MP4)

```
ffmpeg -i inputfile.ts -map 0 -c copy output.mp4

ffmpeg -i segment1.ts -map 0 -filter:v "crop=100:100:iw-100:0" hancock.mp4

convert -delay 100 -loop 0 hancock.mp4 hancock.gif
```

