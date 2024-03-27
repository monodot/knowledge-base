---
layout: page
title: PDF
---

PDF tips and tricks.

## Removing password protection with Littlebirdy

    $ git clone https://github.com/jakepetroules/littlebirdy
    $ cd littlebirdy
    $ ./littlebirdy /path/to/your.pdf

## Compressing a PDF

Using GPL Ghostscript:

    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile=output.pdf input.pdf

## Making a PDF look like a scanned document (Fedora)

First install ImageMagick:

    dnf install imagemagick

Then:

    convert -density 300 -colorspace Gray -depth 8 -quality 85 input.pdf output.pdf

Or:

    convert -density 150 ORIGINAL.pdf -colorspace gray +noise Gaussian -rotate 0.5 -depth 2 SCANNED.pdf

Or:

    convert -density 150 input.pdf -colorspace gray -linear-stretch 3.5%x10% -blur 0x0.5 -attenuate 0.25 +noise Gaussian -rotate 0.5 temp.pdf

    gs -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -sColorConversionStrategy=LeaveColorUnchanged dAutoFilterColorImages=true -dAutoFilterGrayImages=true -dDownsampleMonoImages=true -dDownsampleGrayImages=true -dDownsampleColorImages=true -sOutputFile=output.pdf temp.pdf

