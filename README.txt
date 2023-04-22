# Porcupine-CNC-Mod
Add Spindle and mql capabilities to a 3040 CNC

Porcupine CNC Mod v1

Disclaimer: Use at your own risk, I am
not responsible for any damage, pain, or
injury caused by using this. before attempting
please consider if you have the skill set to
safely work with electricity. Incase that
warning is ignored make 100% sure the cnc box
is unplugged prior to modifying the hardware
even so be careful near capacitors, as they
could still carry a very strong charge.
Also never unplug energized stepper motors, as
you can fry your stepper motor drivers. there
is always the chance this code might not function
or a bad electrical connection causing broken endmills.
keep this in mind, use at your own risk

This software's purpose is to add 
functionality to CNC machines with a 
JP-382c main board. Due to manufacturing 
patterns in China this could compromise of
several brands of CNC machines. to 
complicate matters JP-382c boards are not 
all the same.
This hardware and software solution is
tested and used on a China zone CNC 4 axis. The
control box is labeled as 3 axis td. it also a
tool height probe. You can check compatibility by
testing to see if you detect output from the jp-382
board's lpt port while connected via USB. As the 
software outputs #2, and #3 in "CNC USB Controller"
are changed on and off, you will find ground at lpt
pin 24 and 12vdc signal at pin 16 and pin 1

generated code from this software is being 
sent to the cnc machine via planet cnc's USB 
CNC controller software. This might work
with additional host software options but currently 
remains untested.

A bit of background on these machines, they shipped with
questionable software/licenses. Mach3 and Planet CNC's
USB CNC Controller. In the case of Planet CNC's it appears
China Zone CNC used the code from Planet CNC's DIY Board
and Planet CNC being upset that a commerical product was
cutting in on his product, that and possibly with a hacked
license. I choose to buy a license from Planet CNC, but as
a warning they say the unoffical boards will reset. Its been
2 years, it hasnt reset on me. but I went through a few extra
steps. edit your host file setting planet-cnc.com as 127.0.0.1
install a software firewall, windows users "zone alarm" works
great. Dont let USB CNC Controller access to the internet via
zone alarm. Most importantly buy a software license and help
support the developer. I have no affilation with planet-cnc.com
but I am happy with thier software.

Porcupine CNC Mod https://github.com/Cekiert/Porcupine-CNC-Mod
Developed by: Christopher Ekiert, 2023 and released under
GNU Lesser General Public License v2.1
