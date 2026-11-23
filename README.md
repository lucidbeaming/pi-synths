# pi-synths

Scripts for building music machines on Raspberry Pi.

**Build write-up:** [Setting up a Raspberry Pi 3 to run ZynAddSubFX in a headless configuration](https://lucidbeaming.com/blog/setting-up-a-raspberry-pi-3-to-run-zynaddsubfx-in-a-headless-configuration/)

These are the scripts behind a battery-powered, untethered synth box: the [ZynAddSubFX](https://zynaddsubfx.sourceforge.io/) soft synth running headless on a Raspberry Pi, played from a USB MIDI keyboard, with instruments switched from a phone over wifi. In use it became a pad and drone instrument: complex, rich sounds from a small box with no screen. The blog post above walks through the whole build; this repo holds the scripts it uses.

> **Built in 2017** on a Raspberry Pi 3 with Raspbian Jessie Lite. Current Raspberry Pi OS has changed in ways that affect these scripts; see [On current Raspberry Pi OS](#on-current-raspberry-pi-os).

## The ZynAddSubFX box

| Part | What was used |
|---|---|
| Computer | Raspberry Pi 3, Raspbian Jessie Lite (no desktop) |
| Audio out | [IQaudio Pi-DAC+](https://www.raspberrypi.com/products/iqaudio-dac-plus/) (I²S), with the built-in audio disabled |
| Synth | ZynAddSubFX, compiled on the Pi, running on ALSA without JACK |
| Playing | A USB MIDI keyboard: Arturia MiniLab, Akai MPK mini mk2, or anything that shows up as `mio` |
| Instrument switching | [ZynAddSubFX-WebApp](https://github.com/lucidbeaming/ZynAddSubFX-WebApp) in a phone browser, over OSC |

## Scripts

### [`ZynAddSubFX/required-packages.sh`](ZynAddSubFX/required-packages.sh)

Installs everything needed to build ZynAddSubFX from source: JACK and ALSA headers, FLTK/NTK, FFTW, liblo, mxml, build tools (cmake, autoconf, libtool), and `rtirq-init` for better real-time audio priority. Much of the list comes from the [Zynthian](https://github.com/zynthian/zynthian-sys/tree/master/scripts) project.

### [`ZynAddSubFX/zynlaunch.sh`](ZynAddSubFX/zynlaunch.sh)

Starts ZynAddSubFX headless (unless it's already running) and connects the first MIDI keyboard it finds. The flags are the balance of performance and fidelity found by trial and error on the Pi 3:

| Flag | Meaning |
|---|---|
| `-U` | No GUI |
| `-A=0` | Auto-save off |
| `-a` | Auto-connect (applies to JACK only) |
| `-o 512` | ADsynth oscillator size |
| `-r 96000` | Sample rate |
| `-b 512` | Buffer size |
| `-I alsa -O alsa` | ALSA for MIDI input and audio output, no JACK |
| `-P 7777` | OSC port, which the web app sends instrument changes to |
| `-L "…/0034-Slow Morph_Choir.xiz"` | Instrument loaded at startup |

It then checks `aconnect -o` for an Arturia MiniLab, an Akai MPK mini mk2 or a device named `mio`, in that order, and connects the first one found to ZynAddSubFX. Otherwise it suggests `aconnect -l`. A log line reports whether Zyn "is singing".

## Setup (as built in 2017)

The [blog post](https://lucidbeaming.com/blog/setting-up-a-raspberry-pi-3-to-run-zynaddsubfx-in-a-headless-configuration/) has every step and config file. In short:

1. Flash Raspbian Lite, enable SSH and wifi, run `raspi-config`, update.
2. Real-time tuning: add the `pi` user to the `audio` group with `rtprio 80` and `memlock unlimited`; set the CPU governor to `performance` on all four cores; lower swappiness.
3. Audio: enable the Pi-DAC+ overlay in `/boot/config.txt`, disable the built-in audio, and make it ALSA's default card.
4. Install the build dependencies:

   ```bash
   curl -O https://raw.githubusercontent.com/lucidbeaming/pi-synths/master/ZynAddSubFX/required-packages.sh
   chmod +x required-packages.sh
   ./required-packages.sh
   ```

5. Build ZynAddSubFX from source with SSE disabled and `NoNeonplease=ON` (20–40 minutes on a Pi 3).
6. Copy `zynlaunch.sh` to `/home/pi/` and start it from `/etc/rc.local` at boot:

   ```bash
   su pi -c '/home/pi/zynlaunch.sh >> /tmp/zynaddsubfx.log 2>&1 &'
   ```

7. Install [ZynAddSubFX-WebApp](https://github.com/lucidbeaming/ZynAddSubFX-WebApp) and open `http://<pi-address>:7000` on a phone to switch instruments.

## On current Raspberry Pi OS

Checked against Debian bookworm and trixie, which current Raspberry Pi OS is based on:

- **ZynAddSubFX is packaged** (3.0.6, arm64), so `sudo apt install zynaddsubfx` replaces steps 4 and 5. The packaged instrument banks live under `/usr/share/zynaddsubfx/banks`, not `/usr/local/share`, so the `-L` path in `zynlaunch.sh` becomes `/usr/share/zynaddsubfx/banks/Choir and Voice/0034-Slow Morph_Choir.xiz`.
- `required-packages.sh` names packages that no longer exist (`laditools`, `liblash-compat-dev`, `non-ntk-dev`, `premake`) or were renamed (`libcairo2-dev`, `libfftw3-dev`). Those lines fail.
- Updating the scripts for a current Pi is tracked in [#3](https://github.com/lucidbeaming/pi-synths/issues/3).

## Related projects

- [ZynAddSubFX-WebApp](https://github.com/lucidbeaming/ZynAddSubFX-WebApp): the phone instrument switcher for this box
- [Fluidsynth-Webapp](https://github.com/lucidbeaming/Fluidsynth-Webapp): a similar setup for FluidSynth on a Pi Zero W ([write-up](https://lucidbeaming.com/blog/running-fluidsynth-on-a-raspberry-pi-zero-w/))
- [Camel](https://github.com/lucidbeaming/Camel): an Arduino drone synth

## License

[MIT](LICENSE).
