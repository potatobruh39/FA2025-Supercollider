# MTEC-347 Final
### Michael Chung


This code is simple to use but some steps are necessary to make it function properly. 

First, increase memory allocation using s.options.memSize and then reboot the server. This ensures no memory issues occur as the piece is running. 

Then, tempo clock, all SynthDefs (instruments, FX buses, control buses), and sequences (global variables with Pbind) can be instantiated at the same time using the marked main block of code. The post window should read ‘a Pbind’. Running this block creates all the sound generation/processing, signal routing, and sequencing that we will need.

Finally, at the bottom of the document is the ‘play controls’ section. This is where the piece will be performed. First run the FX block to ensure all FX buses are active. Everything else in this section will be used to start or stop our sounds.


Here is a basic structure of the piece as I imagined it:

* Percussion sounds are added first: first white noise, then perc1, then perc2. Make sure to give space before activating each one, so that the texture can develop.

* After the percussion texture becomes familiar, activate the main synth block. This will immediately play the main sine arpeggio, as well as schedule a lead, pad and bass to appear later.

* The timbre of the sine arpeggio can be changed with the FM envelopes. The first one goes down and the second goes up. These should be triggered as appropriate to add variation.

* A pink noise wave sound can be activated at any time with ~wave. I like to do this shortly after activating the main synth block.

* After letting the code run for a while, you will hear the scheduled lead, pad, and bass sounds enter in a staggered fashion. Once the composition feels to be static, elements should be slowly removed using the stop messages section.

* I imagine the order of stop messages to be as arranged in the code: percussion, synths, and finally the wave sound. Be sure to remove elements one by one and with patience. Ideally, ~wave.set(\time, 1); will cause the wave sound to gradually fade out, but sometimes it doesn’t work. If that is the case use ~wave.free as a backup.