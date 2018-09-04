---
id: 423e5a97-2ecd-46ce-a6d0-80d828a6da0f
title: Measuring the strength of a WiFi connection
date: 2018-09-04
tags: programming
image: 2018-09-04-measuring-the-strength-of-a-wifi-connection.png
---

Recently I switched my ISP provider and with the change I've got
a new WiFi router. The download speed is incredible, 10x the compared
to my previous subscription, but the stability got worse.

As a software engineer, I know my way around computers, but when it
comes to network equipment I'm on the same level as the avarage Joe.
This issue with an unstable WiFi connection was bugging me too much.
I've tried moving my notebook around the appartment and I've noticed
some difference, but it was mostly random.

I realize that it is time to purchase a stronger WiFi router.
However, before I do that, I wanted to find out exactly where is the
source of the issue.

## Measuring Signal Strength

I learned that on OS X there is a utility command that I can invoke to
print the information about the current wireless connection:

``` bash
$ /System/Library/PrivateFrameworks/Apple*.framework/Versions/Current/Resources/airport -I

     agrCtlRSSI: -52
     agrExtRSSI: 0
    agrCtlNoise: -98
    agrExtNoise: 0
          state: running
        op mode: station
     lastTxRate: 117
        maxRate: 289
lastAssocStatus: 0
    802.11 auth: open
      link auth: wpa2-psk
          BSSID: fc:1:7c:50:33:56
           SSID: A
            MCS: 6
        channel: 36
```

We will look into two of the above numbers, the RSSI and Noise.

The first value RSSI (Received Signal Strenght Indicator) is mesauring the
power of the received signal in the wireless network. It uses a logarithmic
scale expressed in decibels (db) and typically ranges from 0 to -100. For a
good quality signal, we want the number to be closer to zero.

The second value Noise, measures the impact of unwanted interfering signal
sources, such as distortion and radio frequency interference. This value is
also measured in decibels (db) from 0 to -120. We want this value to be as
close to the -120 as possible as this indicates little to no noise in the
wireless network.

With the RSSI and Noise, we can calculate Signal-to-Noise margin, a
commonly used value to measure the power of the signal. It is calculated
with the following formula:

```
SNR_Margin = RSSI - Noise
```

Higher values represent better WiFi signals.

With the above formula, I've constructed a bash script for monitoring the
strenght of my WiFi signal.

``` bash
#!/usr/bin/env bash
# file: w.sh

while true; do
  out="$(/System/Library/PrivateFrameworks/Apple*.framework/Versions/Current/Resources/airport -I)"

  rssi=$(echo -e "$out" | grep "CtlRSSI" | awk -F ':' '{ print $2 }')
  noise=$(echo -e "$out" | grep "CtlNoise" | awk -F ':' '{ print $2 }')

  echo "RSSI: $rssi, Noise: $noise, Quality: $((rssi - noise))"

  sleep 1
done
```

Example of monitoring and walking around the appartment:

``` bash
$ bash w.sh

RSSI:  -59, Noise:  -90, Quality: 31
RSSI:  -59, Noise:  -92, Quality: 33
RSSI:  -58, Noise:  -86, Quality: 28
RSSI:  -57, Noise:  -86, Quality: 29
RSSI:  -57, Noise:  -86, Quality: 29
RSSI:  -57, Noise:  -88, Quality: 31
RSSI:  -57, Noise:  -89, Quality: 32
RSSI:  -57, Noise:  -89, Quality: 32
RSSI:  -57, Noise:  -89, Quality: 32
RSSI:  -57, Noise:  -89, Quality: 32
RSSI:  -56, Noise:  -89, Quality: 33
RSSI:  -55, Noise:  -95, Quality: 40
RSSI:  -55, Noise:  -100, Quality: 45
RSSI:  -54, Noise:  -101, Quality: 47
RSSI:  -53, Noise:  -101, Quality: 48
RSSI:  -53, Noise:  -101, Quality: 48
RSSI:  -52, Noise:  -101, Quality: 49
RSSI:  -52, Noise:  -100, Quality: 48
RSSI:  -52, Noise:  -98, Quality: 46
RSSI:  -51, Noise:  -96, Quality: 45
RSSI:  -51, Noise:  -92, Quality: 41
RSSI:  -50, Noise:  -92, Quality: 42
RSSI:  -50, Noise:  -92, Quality: 42
RSSI:  -50, Noise:  -90, Quality: 40
RSSI:  -50, Noise:  -90, Quality: 40
RSSI:  -50, Noise:  -89, Quality: 39
RSSI:  -51, Noise:  -89, Quality: 38
RSSI:  -52, Noise:  -89, Quality: 37
RSSI:  -53, Noise:  -89, Quality: 36
RSSI:  -54, Noise:  -89, Quality: 35
RSSI:  -59, Noise:  -92, Quality: 33
RSSI:  -60, Noise:  -92, Quality: 32
RSSI:  -62, Noise:  -92, Quality: 30
RSSI:  -62, Noise:  -91, Quality: 29
RSSI:  -63, Noise:  -89, Quality: 26
RSSI:  -63, Noise:  -87, Quality: 24
RSSI:  -64, Noise:  -86, Quality: 22
RSSI:  -65, Noise:  -86, Quality: 21
RSSI:  -65, Noise:  -86, Quality: 21
RSSI:  -65, Noise:  -88, Quality: 23
RSSI:  -65, Noise:  -89, Quality: 24
RSSI:  -66, Noise:  -89, Quality: 23
RSSI:  -66, Noise:  -89, Quality: 23
RSSI:  -65, Noise:  -96, Quality: 31
```

I've use the following rules of thumb for my WiFi connection:

- RSSI => -90dB: Unusable connection.
- RSSI (-90dB..-80db): Connection is bad, but I can maybe open my email.
- RSSI (-80dB..-70db): Usable. Major disruptions while browsing the web.
- RSSI (-70dB..-65dB): Usable for email, browsing.
- RSSI (-65dB..-55dB): Usable for Skype/Zoom calls, Gaming, streaming.
- RSSI <= -55dB: Stable connection with no distractions.
