Supported NXP platforms:
  - i.MX 8M Plus EVK

#Building Yocto image:
Prerequisites:
- Installed Ubuntu 20.04 OS or higher on Host System.
- Installed essential Yocto Project host packages:
  ```
  sudo apt install gawk wget git diffstat unzip texinfo gcc build-essential \
  chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils \
  iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
  python3-subunit mesa-common-dev zstd liblz4-tool file locales -y
  sudo locale-gen en_US.UTF-8
  ```
  
1. Create a bin folder in the home directory:
   ```
   mkdir ~/bin
   curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
   chmod a+x ~/bin/repo
   ```
2. Add the following line to the .bashrc file to ensure that the ~/bin folder is in your PATH variable:
   ```
   export PATH=~/bin:$PATH
   ```
3. Create a new working folder for the Yocto sources and images:
   ```
   mkdir imx-yocto-bsp
   ```
4. Check out the NXP i.MX Yocto Board Support Package (BSP) to the working folder and download source files:
   ```
   cd imx-yocto-bsp
   repo init -u https://github.com/nxp-imx/imx-manifest -b imx-linux-nanbield -m imx-6.6.3-1.0.0.xml
   repo sync
   ```
5. Add the Framos meta layers:
   ```
   cd imx-yocto-bsp/sources
   git clone https://github.com/framosimaging/meta-imx8mp-framos
   ```
6. Set the DISTRO and MACHINE variables and do the fsl setup:
   ```
   cd imx-yocto-bsp
   DISTRO=fsl-imx-wayland MACHINE=imx8mp-lpddr4-evk source ./imx-setup-release.sh -b build
   ```
7. Build an image using bitbake with Framos layer included:
   ```
   source sources/meta-imx8mp-framos/setup/setup-env-imx8mp-framos -b build-imx8mp-framos
   bitbake imx-image-multimedia
   ```
8. Flash an SD card image:
- Insert an SD card of at least 8 GB size into an SD card writer.
  ```
  cd ~/imx-yocto-bsp/build-imx8mp-framos/tmp/deploy/images/imx8mp-lpddr4-evk
  zstdcat imx-image-multimedia-imx8mp-lpddr4-evk.rootfs.wic.zst | sudo dd of=/dev/sd<partition> bs=1M conv=fsync
  ```
- Set SW4 switch to 0011 on the board and connect to the platform debug port via USB to the host and then connect to target using serial port (we used Teraterm with 115200 bauds).
9. Boot the board and press any key from terminal to enter u-boot and set the appropriate device tree as fdtﬁle (example for IMX662):
   ```
   setenv fdtfile imx8mp-evk-imx662.dtb
   saveenv
   boot
   ```
 
# Test streaming and mode switching on target
- If you are using only one sensor make sure to use CSI1 port.
- To test that everything is working as expected run:
  ```
  gst-launch-1.0 -v v4l2src device=/dev/video2 ! waylandsink
  ```
- If you are using dual mode you can use command:
  ```
  gst-launch-1.0 imxcompositor_g2d name=comp sink_0::xpos=0 sink_0::ypos=0 sink_0::width=960 sink_0::height=1080 sink_1::xpos=960 sink_1::ypos=0 sink_1::width=960 sink_1::height=1080 ! video/x-raw! waylandsink v4l2src device=/dev/video2 ! video/x-raw,format=YUY2,framerate=30/1 ! comp.sink_0 v4l2src device=/dev/video3 ! video/x-raw,format=YUY2,framerate=30/1 ! comp.sink_1
  ```
- To switch the streaming mode edit the isp mode conﬁguration */opt/imx8-isp/bin/run.sh* under desired conﬁguration (single or dual) by setting MODE = "<MOD_NUM>"
- Restart the isp server with:
  ```
  /opt/imx8-isp/bin/start_isp.sh
  ```
