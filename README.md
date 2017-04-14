# raspberrypi
[Raspberry PI](https://www.raspberrypi.org/products/raspberry-pi-2-model-b/) 2 solutions for IP camera DLINK DSC930l
1. [DLINK Camera](http://www.dlink.com/uk/en/products/dcs-930l-wireless-n-network-camera) is run in motion detection(3fps) mode with an external ftp server support
2. Raspberry receives data from camera via [ftp server](https://security.appspot.com/vsftpd.html)
3. Created cronjob takes appropriate frames and create mpeg videos with [ffmpeg](https://ffmpeg.org/) using H264 codec.
4. A new .mp4 video uploaded each time at google disk using this [beatiful python tool](https://github.com/dsoprea/GDriveFS)
5. Email notifications may be specified at .cf file. Web interface for cronjob allows to update a config

![webinterface](screenshot.png?raw=true "bootstrap baby")


