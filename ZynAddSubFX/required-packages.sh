#!/bin/bash
# Installs what the ZynAddSubFX box needs on Raspberry Pi OS (Debian bookworm or trixie).
#
#   ./required-packages.sh                 packaged ZynAddSubFX (recommended)
#   ./required-packages.sh --from-source   build dependencies, to compile ZynAddSubFX yourself
#
# First written for Raspbian Jessie (2017), when ZynAddSubFX had to be built
# from source. Current Raspberry Pi OS packages it (3.0.6).
set -e

sudo apt-get update

# aconnect (alsa-utils) wires the MIDI keyboard to the synth in zynlaunch.sh;
# rtirq-init gives audio interrupts real-time priority.
sudo apt-get install -y alsa-utils rtirq-init

if [ "$1" = "--from-source" ]; then
  # Debian's own build dependencies for zynaddsubfx, without docs and tests
  sudo apt-get install -y build-essential git cmake pkgconf \
    dssi-dev fluid libasound2-dev libfftw3-dev libfltk1.3-dev libgl-dev \
    libjack-jackd2-dev liblo-dev libmxml-dev libxpm-dev lv2-dev zlib1g-dev
else
  sudo apt-get install -y zynaddsubfx
fi
