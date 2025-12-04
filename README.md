# A PicoMite Library

This git repository is a collection of programs written in PicoMite BASIC for the PicoCalc.

The structure is like this:

- `docs\` the scripts used to generate [the documentation](https://aefarrell.github.io/picomite_library/)
- `math\` BASIC code for doing math
- `art\` BASIC code for generating cool visualizations and art
- `utils\` useful utilities
- `toys\` little toy programs

## Transferring with the PicoCalc

The fastest way to transfer files, in bulk, is via the SD card -- if you have an SD card reader. Alternatively you can connect to the PicoCalc via the serial connection. First turn on the PicoCalc and connect to your computer via the USB-C port on the PicoCalc.

I use linux at home, and use [minicom](https://salsa.debian.org/minicom-team/minicom) to connect via the terminal. The first steps are to determine which device the PicoCalc has connected as, and add the appropriate permissions for the user to connect.

### Identifying the PicoCalc serial device

To find the device the PicoCalc has been mapped to

~~~bash

dmesg | grep -i uart

~~~

Scrolling through the output I find the following

~~~
[ 1053.104717] ch341 1-1:1.0: ch341-uart converter detected
[ 1053.105166] usb 1-1: ch341-uart converter now attached to ttyUSB0
~~~

> [!TIP]
> I use popOS at home and I found initially that the PicoCalc would connect, attach to ttyUSB0, and immediately disconnect. The solution was to uninstall `brltty`.

Which is the PicoCalc being detected and attached to `/dev/ttyUSB0`. The user requires read-write permission to connect to the device, which can be accomplished by adding it to the group the device is in with `ls`.

~~~bash

ls -lah /dev/ttyUSB0

~~~


On my machine it is in the group `dialout`

~~~
crw-rw---- 1 root dialout 188, 0 Dec  3 19:06 /dev/ttyUSB0
~~~

After the user has been added to the group (and possibly after logging out and back in), the PicoCalc can be connected to without having to use `sudo`.

### Configuring minicom

Minicom will look for a config file in `$HOME` when given an appropriate name, and if one isn't found it will create it, e.g. this creates a config file named 'picocalc'

~~~bash

minicom picocalc

~~~

From within minicom hit `Ctrl-A` followed by `o` to open the configuration menu and adjust the default settings to the PicoCalc. This will save a `.minirc.picocalc` in `$HOME`, mine looks like this:

~~~
# Machine-generated file - use setup menu in minicom to change parameters.
pu port             /dev/ttyUSB0
pu rtscts           No 
~~~

### Connecting to the PicoCalc

Once minicom is configured, a serial connection can be opened by simply calling the config file

~~~bash

minicom picocalc

~~~

This opens a terminal and any keystrokes are mirrored on the PicoCalc. To send a file from the computer to the PicoCalc, first enter the following into the PicoCalc

~~~
xmodem receive "your/directory/and/file"
~~~

Then hit `Ctrl-A` followed by `s` in minicom and select the file you wish to send. Since minicom is connected as a terminal this all be done in the same terminal window.

To do the reverse, first enter the following into the PicoCalc

~~~
xmodem send "your/directory/and/file"
~~~

Then hit `Ctrl-A` followed by `r` in minicom and give the filename to be saved locally. Again, with minicom connected as a terminal this can all be done in the same window.

Transferring programs and text files with [xmodem](https://en.wikipedia.org/wiki/XMODEM) is relatively fast, but anything large like an image file or music, is fairly slow and is probably worth transferring back and forth via the SD card.
