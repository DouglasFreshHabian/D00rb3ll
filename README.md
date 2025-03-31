#  🚪🔔 D00rb3ll

<img src="https://capsule-render.vercel.app/api?type=waving&color=auto&height=300&section=header&text=IoT_Hacking&desc=D00rb3ll&animation=blinkingrender&fontSize=90" />

<a href="https://git.io/typing-svg"><img src="https://readme-typing-svg.demolab.com?font=Fira+Code&pause=1000&color=18ACF7&width=435&lines=Information+Gathering+%26+Recon...;Obtaining+%26+Analyzing+the+Firmware;Extracting+%26+Analyzing+the+Filesystem;Emulation+%26+Dynamic+Analysis...;Runtime+Analysis+%26+Exploitation..." alt="Typing SVG" /></a>

# About
### This repo contains files that go along with my youtube series on IoT Hacking a Video Camera Doorbell. I will update the repository as we progress through the series. 

## Why This Project? 🗯

The goal of this project is to offer a transparent look into the firmware of a widely used consumer device. As part of my ongoing reverse engineering efforts, I will continue to add insights, static and dynamic analysis results, and modifications to this repository.

Whether you’re a Linux enthusiast, a security researcher, a reverse engineer, or a hacker, this project aims to provide useful resources to help uncover how the firmware operates and potentially identify vulnerabilities, security flaws, or other points of interest.


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

In this video we gained a non-interactive shell on an IoT device by connecting a *usb-to-ttl* adpater
to the RX and TX pads on the board of the device. We used `minicom` for a serial shell with a baud 
rate of **115200**. Though we could not interact with the device we were able to view and capture the
boot up logs, which allowed us to learn a lot about the device.  

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

## 👢 [Bootlogs:](https://github.com/DouglasFreshHabian/D00rb3ll/blob/main/Bootlogs.txt)
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
script is called [Lookup.sh](https://github.com/DouglasFreshHabian/D00rb3ll/blob/main/Lookup.sh) and you can find that in this repo as well. It accepts a log file as 
input, extracts the ip address using the above regex, sorts them to remove duplicates and prints the
remaining address to the screen with a total count. It then checks to see if you have `geoiplookup`
installed, checks for an internet connection and proceeds to execute two commands on each one of
the ip address, `geoiplookup` and `whois`. It prints the results to the screeen and saves the results
to a file. As of right now, it only deals with ip addresses. Perhaps we can add the some sort of
similiar functionality for urls too...

We learned a lot about this firmware just from a log file. One of perhaps the most important things, was that it is using a Linux based operating system based of off ***OpenWRT***. 
The name of this operating system is ***Tina Linux.*** If you haven't done so already, go over to my youtube channel, hit that like button, subscribe and check out the next video...

```bash
   $ sed -n '36,47p' Bootlogs.txt

        BusyBox v1.27.2 () built-in shell (ash)

         _____  _              __     _
        |_   _||_| ___  _ _   |  |   |_| ___  _ _  _ _
          | |   _ |   ||   |  |  |__ | ||   || | ||_'_|
          | |  | || | || _ |  |_____||_||_|_||___||_,_|
          |_|  |_||_|_||_|_|  Tina is Based on OpenWrt!
         ----------------------------------------------
         Tina Linux (Neptune, 5C1C9C53)
         ----------------------------------------------
```
>**💡Tip:**
> You can use `sed` to display only lines 36 to 47 from the Bootlogs.txt file.


# ["Hacking an IoT Video Doorbell: Extracting & Analyzing Firmware"](https://youtu.be/fGCQTk4-eE4?si=HizJNpvhUviEKrlf) 

## ![Hacking an IoT Doorbell - Youtube Thumbnail-2.](https://github.com/DouglasFreshHabian/D00rb3ll/blob/main/Graphics/Thumbnail-Video-2.png)

The firmware here was extracted using a CH341A SPI programmer and the `flashrom` utility. The resulting firmware image, doorbell.bin, is shared in its raw form, enabling anyone to dive into static analysis, emulation, or any other form of research.


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
>**💡Important:**
> Always probe first to try and get the name of the chip.

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
## Before we begin analysis, it's a good idea to first get a hash of the image:
There are several command line utilities that we could use for this including `sha256sum,` `sha512sum` and `md5sum.`

Getting a md5 hash:
```bash
   md5sum firmware.bin
   5169b9d806903c2df8c07f6d6ec06171  doorbellfirm.bin
```

Getting a sha256 hash:
```bash
   sha256sum firmware.bin
   59df39887e8e72a9d9b0847bbf7a73aa9afacf9fa5ec1a771493160e470f2131  doorbellfirm.bin
```

Getting a sha512 hash:
```bash
   sha512sum firmware.bin
   090ba7fcc514530399953de1e65dfc08851aabf08905eab21d501c0630900d445deda27634b5f70b5fe3861ffa735d001987ece7739f31e84a3e8c2f03a0b178  doorbellfirm.bin

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
   binwalk doorbell.bin             # Ran with no options, binwalk will scan the image and print the results to the screen

   binwalk -E doorbell.bin          # Calculates file entropy which tells us whether the firmware is encrypted or not

   binwalk -eM doorbell.bin         # Extract known file types (-e), and recursively scan extracted files (-M)
```
## Basic Analysis of the Firmware's Filesystem: 🗃🕵️

#### We are performing <ins>*static*</ins> analysis, later in the series we look at <ins>*dynamic*</ins> analysis.

##### Here are some of the things we are looking for:
+ what's inside /etc/shadow and /etc/passwd
+ configuration files
+ script files
+ .bin files
+ keywords such as admin, password, remote, AWS keys, etc.
+ binaries such as ssh, tftp, dropbear, etc.
+ banned c functions
+ command injection vulnerable functions
+ URLs, email addresses and IP addresses
+ and more…

#### Interesting... Inside of the <ins>passwd</ins> file we find a *root* user with a shell!

```bash

  $ cat passwd

      root:$1$0WlvKUDR$.yqcW5hBKyVJKCHQ4njdB/:0:0:root:/root:/bin/ash
      daemon:*:1:1:daemon:/var:/bin/false
      ftp:*:55:55:ftp:/home/ftp:/bin/false
      network:*:101:101:network:/var:/bin/false
      nobody:*:65534:65534:nobody:/var:/bin/false
```
#### Next we check the <ins>**shadow**</ins> file:

```bash
   $ cat shadow

      root:91rMiZzGliXHM:1:0:99999:7:::
      daemon:*:0:0:99999:7:::
      ftp:*:0:0:99999:7:::
      network:*:0:0:99999:7:::
      nobody:*:0:0:99999:7:::
```
#### This is easily crackable even for a noob! We're going to be using `john` also known as *John The Ripper.*
We are only concerned with the first line of the `shadow` file. Copy that line and paste it into a file called
hash.txt outside of the firmware image's filesystem.

```bash
   $ cat hash.txt
      
      root:91rMiZzGliXHM:1:0:99999:7:::
```
To install John:

```bash
   sudo apt install john
```
And finally, the only thing needed is to run `john` on the file containing the hash, no options:

```bash
   $ john hash.txt

       Created directory: /home/kali/.john
       Using default input encoding: UTF-8
       Loaded 1 password hash (descrypt, traditional crypt(3) [DES 256/256 AVX2])
       Will run 4 OpenMP threads
       Proceeding with single, rules:Single
       Press 'q' or Ctrl-C to abort, almost any other key for status
       Almost done: Processing the remaining buffered candidate passwords, if any.
       Proceeding with wordlist:/usr/share/john/password.lst
       tina             (root)     
       1g 0:00:00:01 DONE 2/3 (2025-03-31 08:15) 0.9803g/s 26739p/s 26739c/s 26739C/s 123456..HALLO
       Use the "--show" option to display all of the cracked passwords reliably
       Session completed. 

$ john hash.txt --show

       root:tina:1:0:99999:7:::
  
       1 password hash cracked, 0 left
 ```
## Password: 🗝 The password for the root user is <ins>tina.</ins>
I think it's safe to say that ***tina*** comes from ***Tina Linux*** and that implies that default passwords are being used. I was able to verify this by performing the same steps on another doorbell, same manufacturer. 
The password was in fact the same, ***tina***. 

## Contributing & Collaboration: 🤝

#### This is an open project, and I welcome contributions and feedback from the community. If you have insights, improvements, or additional findings related to the firmware, please feel free to submit issues or pull requests.

## Ongoing Reverse Engineering Efforts:🥈🏆🥉

## Here is our firmware testing checklist: 📋
- [x] Information Gathering & Recon
- [x] Obtaining firmware
- [x] Analyzing firmware
- [x] Extracting the filesystem
- [x] Anaylzying the filesystem
- [ ] Emulating firmware
- [ ] Dynamic analysis
- [ ] Runtime analysis
- [ ] Binary Exploitaion
#### As I continue to reverse engineer the firmware, I will document my findings and methodologies here. 

## Feedback & Questions:❓❔❓

Your thoughts, questions, and feedback are greatly appreciated! Feel free to open an issue or leave a comment. Let’s collaborate and make this project even better.

Thank you for checking out [D00rb3ll](https://github.com/DouglasFreshHabian/d00rb3ll). Stay tuned for future updates, and happy reverse engineering!


## Resources: [FreshPdfLibrary](https://github.com/DouglasFreshHabian/FreshPdfLibrary)
In this repo, you find the guide that I am using in this series as well as a lot more!!!

### If you have not done so already, please head over to the channel and hit that subscribe button to show some support. Thank you!!!

## 👊 [https://www.youtube.com/@DouglasHabian-tq5ck](https://www.youtube.com/@DouglasHabian-tq5ck) 







<!-- dfresh@tutanota.com Fresh Forensics, LLC 2025 -->
