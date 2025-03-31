#  🚪🔔 D00rb3ll

<img src="https://capsule-render.vercel.app/api?type=waving&color=auto&height=300&section=header&text=IoT_Hacking&desc=D00rb3ll&animation=blinkingrender&fontSize=90" />

<a href="https://git.io/typing-svg"><img src="https://readme-typing-svg.demolab.com?font=Fira+Code&pause=1000&color=18ACF7&width=435&lines=Information+Gathering+%26+Recon...;Obtaining+%26+Analyzing+the+Firmware;Extracting+%26+Analyzing+the+Filesystem;Emulation+%26+Dynamic+Analysis...;Runtime+Analysis+%26+Exploitation..." alt="Typing SVG" /></a>

# About
### This repo contains files that go along with my youtube series on IoT Hacking a Video Camera Doorbell. I will update the repository as we progress through the series. 

## Why This Project? 🗯

The goal of this project is to offer a transparent look into the firmware of a widely used consumer device. As part of my ongoing reverse engineering efforts, I will continue to add insights, static and dynamic analysis results, and modifications to this repository.

Whether you’re a Linux enthusiast, a security researcher, a reverse engineer, or a hacker, this project aims to provide useful resources to help uncover how the firmware operates and potentially identify vulnerabilities, security flaws, or other points of interest.


## Video 1.
# 📷 ["Hacking an IoT Video Doorbell - What's Inside?"](https://youtu.be/dVZNmC5-uO4?si=WXdHWTCoSJMnTiCV)

## ![Hacking an IoT Doorbell - Youtube Thumbnail.](https://github.com/DouglasFreshHabian/D00rb3ll/blob/main/Thumbnail-1.png)

## The first video was posted and is titled, ["Hacking an IoT Video Doorbell - What's Inside?"](https://youtu.be/dVZNmC5-uO4?si=WXdHWTCoSJMnTiCV)

## Tools: 🛠

### Software: 💾
  1. flashrom:  To interface with the SPI chip.
  2. strings:   For gathering information from the binary.
  3. binwalk:   For unpacking and extracting files from the firmware.

### Hardware: 💻
  1. [USB to TTL Adapter](https://amzn.to/4h6SqPY)
  2. [PCBite Probes](https://amzn.to/4f4CbRr)
  3. Computer running Linux (kali Linux, Ubuntu)

## Methodology: 🔍🌍

In this video we gained a non-interactive shell on an IoT device by connecting a usb-to-ttl adpater
to the RX and TX pads on the board of the device. We used `minicom` for a serial shell with a baud 
rate of 115200. Though we could not interact with the device we were able to view and capture the
boot up logs, which allows us to learn a lot about the device. This device is using an operating
system called Tina Linux. 

### Determine the name & location of the usb-to-ttl adapter when it is plugged in:
```bash
   sudo dmesg -w
```
### Time to run Minicom...
```bash
   minicom -D /dev/ttyUSB0 -b 115200 -C Bootlogs.txt
```
### Let's quicky breakdown this command:
```
minicom
 -D, --device              # Specify the device, typically attached to '/dev/ttyUSB0' in the Linux filesystem
 -b, --baudrate            # Specify the baud rate, typically a value of 115200 and then perhaps 9600 
 -C, --capturefile=FILE    # Open capture file at startup and whatever you get on the screen get saved to a logfile.
```

## 👢 [Bootlogs](https://github.com/DouglasFreshHabian/D00rb3ll/blob/main/Bootlogs.txt)
I have included the bootlogs file in this repo so that you can follow along with the first video.
One of the things that we did was pull out all of the ip address using regex:

```bash
   grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
```
There were many duplicates so we piped the ouput into `sort -u`

```bash
   grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort -u
```

We also ran a custom `bash` script on the log file to automate some of these manual tasks. That bash
script is called `Lookup.sh` and you can find that in this repo as well. It accepts a log file as 
input, extracts the ip address using the above regex, sorts them to remove duplicates and prints the
remaining address to the screen with a total count. It then checks to see if you have `geoiplookup`
installed, checks for an internet connection and proceeds to execute two commands on each one of
the ip address, `geoiplookup` and `whois`. It prints the results to the screeen and saves the results
to a file. As of right now, it only deals with ip addresses. Perhaps we can add the some sort of
similiar functionality for urls too...

## Video 2.
# 📷 ["Hacking an IoT Video Doorbell: Extracting & Analyzing Firmware"](https://youtu.be/dVZNmC5-uO4?si=WXdHWTCoSJMnTiCV)

## ![Hacking an IoT Doorbell - Youtube Thumbnail-2.](https://github.com/DouglasFreshHabian/D00rb3ll/blob/main/Graphics/Thumbnail-Video-2.png)

The firmware here was extracted using a CH341A SPI programmer and the `flashrom` utility. The resulting firmware image, merkury.bin, is shared in its raw form, enabling anyone to dive into static analysis, emulation, or any other form of research.


## Tools: 🛠

### Software: 💾
  1. flashrom:  To interface with the SPI chip.
  2. strings:   For gathering information from the binary.
  3. binwalk:   For unpacking and extracting files from the firmware.

### Hardware: 💻
  1. [ch341a_spi bios/eeprom spi flash chip programmer](https://amzn.to/3BKu12p)
  2. Computer running Linux (kali Linux, Ubuntu)

## Methodology: 🔍🌍

Probe for the flash chip:
```bash
   flashrom --programmer ch341a_spi
```
Read and dump the firmware:
```bash
    flashrom --programmer ch341a_spi --chip [Chip Name] --read doorbell-1.bin
```

It is a good idea to dump the firmware twice just to make sure you have the complete image.
```bash
    flashrom --programmer ch341a_spi --chip [Chip Name] --read doorbell-2.bin
```

Then compare image 1 with image 2 and if there are no differences, you know you have the entire, non-corrupted image:
```bash
   diff --side-by-side doorbell-1.bin doorbell-2.bin
```
## Basic Analysis of the Firmware: 💻🕵️  
To gather basic strings and identify potential embedded information in the firmware before performing further analysis:
Commands:
```bash
   file doorbell.bin                # Determine the file type

   binwalk doorbell.bin             # Ran with no options, binwalk will scan the image and print the results to the screen

   strings -n 10 doorbell.bin       # Strings will print any sequences of "human-readable" characters, that are atleast 10 characters long (-n 10)

   hexdump -C doorbell.bin | head               # Looking for signatures in the header
```
## Unpacking the Firmware: 🔐🌐
To unpack the firmware and extract embedded files or hidden elements, I used binwalk:
```bash
   binwalk merkury.bin             # Ran with no options, binwalk will scan the image and print the results to the screen

   binwalk -E merkury.bin          # Calculates file entropy which tells us whether the firmware is encrypted or not

   binwalk -eM merkury.bin         # Extract known file types (-e), and recursively scan extracted files (-M)
```
## Basic Analysis of the Firmware Filesystem: 🗃🕵️



## Contributing & Collaboration

This is an open project, and I welcome contributions and feedback from the community. If you have insights, improvements, or additional findings related to the firmware, please feel free to submit issues or pull requests.

## Ongoing Reverse Engineering Efforts

As I continue to reverse engineer the firmware, I will document my findings and methodologies here. 

  

## Feedback & Questions

Your thoughts, questions, and feedback are greatly appreciated! Feel free to open an issue or leave a comment. Let’s collaborate and make this project even better.

Thank you for checking out ***D00rb3ll***. Stay tuned for future updates, and happy reverse engineering!

### If you have not done so already, please head over to the channel and hit that subscribe button to show some support. Thank you!!!

## 👍 [https://www.youtube.com/@DouglasHabian-tq5ck](https://www.youtube.com/@DouglasHabian-tq5ck) 





<!-- dfresh@tutanota.com Fresh Forensics, LLC 2025 -->
