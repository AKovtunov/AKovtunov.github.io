#!/usr/bin/env bash
# One-off helper: download the images for the two imported Diatom posts into
# the local /images/ folders so the blog is self-contained (no 3rd-party deps).
# Run once from the repo root:  bash fetch-diatom-images.sh
# Safe to delete this file afterwards.
set -euo pipefail
cd "$(dirname "$0")"

base="https://diatomenterprises.com/wp-content/uploads"

mkdir -p images/alexa_ruby images/voice_assistants

echo "Downloading images for: Enhance Your Business Functions Using Alexa on Ruby"
curl -fsSL "$base/2018/09/Alexa-on-Ruby_cover.jpg" -o images/alexa_ruby/Alexa-on-Ruby_cover.jpg
curl -fsSL "$base/2018/08/DSC_0191.jpg"            -o images/alexa_ruby/DSC_0191.jpg
curl -fsSL "$base/2018/08/download-25.png"         -o images/alexa_ruby/download-25.png
curl -fsSL "$base/2018/08/download-7.png"          -o images/alexa_ruby/download-7.png
curl -fsSL "$base/2018/08/download-6.png"          -o images/alexa_ruby/download-6.png
curl -fsSL "$base/2018/08/download-8.png"          -o images/alexa_ruby/download-8.png
curl -fsSL "$base/2018/08/download-9.png"          -o images/alexa_ruby/download-9.png
curl -fsSL "$base/2018/08/Untitled-drawing-1.png"  -o images/alexa_ruby/Untitled-drawing-1.png

echo "Downloading images for: Making Voice Assistants to Serve Your Needs"
curl -fsSL "$base/2018/09/cover_voice_assistant.jpg" -o images/voice_assistants/cover_voice_assistant.jpg
curl -fsSL "$base/2018/08/DSC_0234.jpg"              -o images/voice_assistants/DSC_0234.jpg
curl -fsSL "$base/2018/08/DSC_0236.jpg"              -o images/voice_assistants/DSC_0236.jpg
curl -fsSL "$base/2018/08/DSC_0246-1.jpg"            -o images/voice_assistants/DSC_0246-1.jpg
curl -fsSL "$base/2018/08/DSC_0232.jpg"              -o images/voice_assistants/DSC_0232.jpg

echo "Done. Downloaded images:"
ls -1 images/alexa_ruby images/voice_assistants
