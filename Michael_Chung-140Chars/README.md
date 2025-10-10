# 140 Character Assignment

I wanted to approach this assignment using both buffers and native synthesis UGens.

# Buffer-based approach

For the code using a buffer, I wanted to make some kind of pseudo granulator based on recorded mic input.

To accomplish this, I created a buffer with Buffer.alloc set to a length of 2 seconds (88200 frames). I used RecordBuf to take in audio from the user and PlayBuf to play this audio back.

In order to create interesting playback effects, I used the Rand UGen to randomize PlayBuf's rate and start position, as well as the frequency of a Saw oscillator that would act as a trigger. This worked to create random playback parameters, but because PlayBuf is not dynamic, it would simply loop one 'snapshot' over and over again.

I then looked into other playback options and found the BufRd UGen which could handle dynamic buffer indeces. In order to scrub the buffer like a granulator would, I used a SinOsc modulated by noise with an amplitude of 88200 (the size of the buffer) to control the index of the BufRd. This ended up being quite a straightforward setup since BufRd is meant for this kind of effect, but the result was quite fun nonetheless.

# Synthesis approach

I also wanted to try creating something like the example 140 character systems, since they require a very different approach from a buffer-based effect. I first started with 'percussion' elements, derived from Bruno Ruviaro's micromoog code in the SuperCollider Tweets Wiki (https://ccrma.stanford.edu/wiki/SuperCollider_Tweets). I used a PinkNoise UGen and gated it with an LFPulse. This pulse was modulated with another LFPulse to create a short-short-short-long pattern, mimicking a hi-hat and snare pattern. I also used a CombN as a delay line.

For the 'melodic' element, I used LFCub and did frequency modulation with SinOsc. The SinOsc was modulated by an LFPulse so the FM could be synced to the percussion. After tweaking the frequency and phase of the gating pulses, the LFCub would jump in pitch (from FM) on downbeats and the percussion would land on upbeats.

### Debugs

Buffer:
- No output when using LFNoise2 for randomization; PlayBuf needs static random generation since many of its parameters are not dynamic. 
- Had no sound when using SinOsc to scrub; needed to increase amplitude to 88200 because the sine wave represented buffer index
- Had 'uncontrolled' modulation; SinOsc default frequency was too high

Synthesis:
- FM stops working after a brief moment of sound; LFPulse has to be biased in the FM system
- FM barely audible; output of LFPulse inside SinOsc needs to be multiplied
- 'melody' and 'percussion' not in sync; lots of frequency and phase adjustments in LFPulse
- Pink noise burts insanely loud; tame them with the multiply argument