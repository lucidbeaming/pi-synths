# pi-synths

Scripts for building music machines on Raspberry Pi.

**Build write-up:** [Setting up a Raspberry Pi 3 to run ZynAddSubFX in a headless configuration](https://lucidbeaming.com/blog/setting-up-a-raspberry-pi-3-to-run-zynaddsubfx-in-a-headless-configuration/)

These are the scripts behind a battery-powered, untethered synth box: the [ZynAddSubFX](https://zynaddsubfx.sourceforge.io/) soft synth running headless on a Raspberry Pi, played from a USB MIDI keyboard, with instruments switched from a phone over wifi. In use it became a pad and drone instrument: complex, rich sounds from a small box with no screen. The blog post above walks through the whole build; this repo holds the scripts it uses.

> **Built in 2017** on a Raspberry Pi 3 with Raspbian Jessie Lite. The scripts are updated for current Raspberry Pi OS (Debian bookworm and trixie), where ZynAddSubFX is packaged.

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

Installs ZynAddSubFX from Raspberry Pi OS's packages, plus `alsa-utils` (for `aconnect`) and `rtirq-init` (better real-time audio priority). With `--from-source` it installs the build dependencies instead (Debian's own list for its ZynAddSubFX package), for compiling a newer version yourself.

### [`ZynAddSubFX/zynlaunch.sh`](ZynAddSubFX/zynlaunch.sh)

Starts ZynAddSubFX headless (unless it's already running) and connects the first MIDI keyboard it finds. It loads its startup instrument from `/usr/share/zynaddsubfx/banks` (the package) or `/usr/local/share/zynaddsubfx/banks` (a source build), whichever exists. The flags are the balance of performance and fidelity found by trial and error on the Pi 3:

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
| `-L "$BANKS/Choir and Voice/0034-Slow Morph_Choir.xiz"` | Instrument loaded at startup |

It then checks `aconnect -o` for an Arturia MiniLab, an Akai MPK mini mk2 or a device named `mio`, in that order, and connects the first one found to ZynAddSubFX. Otherwise it suggests `aconnect -l`. A log line reports whether Zyn "is singing".

## Setup

The [blog post](https://lucidbeaming.com/blog/setting-up-a-raspberry-pi-3-to-run-zynaddsubfx-in-a-headless-configuration/) has every step and config file from the 2017 build. On current Raspberry Pi OS:

1. Flash Raspberry Pi OS Lite with Raspberry Pi Imager (it sets up SSH and wifi), then update.
2. Real-time tuning, as in the post: add your user to the `audio` group with `rtprio 80` and `memlock unlimited`; set the CPU governor to `performance`; lower swappiness.
3. Audio: enable your DAC's overlay in the boot `config.txt` (the box used an IQaudio Pi-DAC+), disable the built-in audio, and make the DAC ALSA's default card.
4. Install ZynAddSubFX and the tools the launch script uses:

   ```bash
   git clone https://github.com/lucidbeaming/pi-synths.git
   cd pi-synths/ZynAddSubFX
   ./required-packages.sh
   ```

5. Start it at boot. The post used `/etc/rc.local`, which current Raspberry Pi OS no longer has; a cron `@reboot` entry does the same (`crontab -e`, as your user):

   ```
   @reboot /home/pi/pi-synths/ZynAddSubFX/zynlaunch.sh >> /tmp/zynaddsubfx.log 2>&1
   ```

6. Install [ZynAddSubFX-WebApp](https://github.com/lucidbeaming/ZynAddSubFX-WebApp) and open `http://<pi-address>:7000` on a phone to switch instruments.

### Building from source

To compile ZynAddSubFX yourself (for a newer version than the package), install the build dependencies, then build with CMake. Builds take a while on a Pi.

```bash
./required-packages.sh --from-source
git clone --recurse-submodules https://github.com/zynaddsubfx/zynaddsubfx.git
cd zynaddsubfx && mkdir build && cd build
cmake .. && make && sudo make install
```

A source build installs its banks under `/usr/local/share`, and `zynlaunch.sh` finds them there too.

## Related projects

- [ZynAddSubFX-WebApp](https://github.com/lucidbeaming/ZynAddSubFX-WebApp): the phone instrument switcher for this box
- [Fluidsynth-Webapp](https://github.com/lucidbeaming/Fluidsynth-Webapp): a similar setup for FluidSynth on a Pi Zero W ([write-up](https://lucidbeaming.com/blog/running-fluidsynth-on-a-raspberry-pi-zero-w/))
- [Camel](https://github.com/lucidbeaming/Camel): an Arduino drone synth

## License

[MIT](LICENSE).
