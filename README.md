# D00rb3ll
This repo contains files that go along with my youtube series on IoT Hacking a Video Camera Doorbell

I will update the repository as we progress through the series. The first video was posted and is
titled, "Hacking an IoT Video Doorbell - What's Inside?". The youtube link to view the video is:
  
  https://youtu.be/dVZNmC5-uO4?si=WXdHWTCoSJMnTiCV

In this video we gained a non-interactive shell on an IoT device by connecting a usb-to-ttl adpater
to the RX and TX pads on the board of the device. We used minicom for a serial shell with a baud 
rate of 115200. Though we could not interact with the device we were able to view and capture the
boot up logs, which allows us to learn a lot about the device. This device is using an operating
system called Tina Linux. 

I have included the bootlogs file in this repo so that you can follow along with the first video.
One of the things that we did was pull out all of the ip address using regex:

  grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'

There were many duplicates so we piped the ouput into sort -u 

  grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort -u

We also ran a custom bash script on the log file to automate some of these manual tasks. That bash
script is called Lookup.sh and you can find that in this repo as well. It accepts a log file as 
input, extracts the ip address using the above regex, sorts them to remove duplicates and prints the
remaining address to the screen with a total count. It then checks to see if you have geoiplookup
installed, checks for an internet connection and proceeds to execute two commands on each one of
the ip address, geoiplookup and whois. It prints the results to the screeen and saves the results
to a file. As of right now, it only deals with ip addresses. Perhaps we can add the some sort of
similiar functionality for urls too...

If you have not done so already, please head over to the channel at the following url:
  
  https://www.youtube.com/@DouglasHabian-tq5ck

and hit that subscribe button to show some support. Thank you...!

[Thumbnail-1](https://github.com/user-attachments/assets/4bb68eea-3c79-4a0c-b6dc-674db5c345fe)

