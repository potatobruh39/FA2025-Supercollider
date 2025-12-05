//more memory is required for certain sounds

s.options.memSize = 16777216; // first increase memory

s.reboot;                     // then reboot

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MAIN BLOCK, RUN THIS FIRST TO CREATE ALL SOUNDS AND BUSES//////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

(
{

t = TempoClock.new(60/60); // 120 BPM

~fxBus1 = Bus.audio(s, 2);
~fxBus2 = Bus.audio(s, 2);
~fxBus3 = Bus.audio(s, 2);

~modfreqBus = Bus.control(s, 1);


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// SYNTHDEFS ///////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

SynthDef(\whitenoise, {
	arg atk, sus, rel, pan;
	var sig, env;

	env = EnvGen.kr(Env.linen(atk, sus, rel, level: 1), doneAction: 2);

	sig = WhiteNoise.ar(0.1);

	sig = Pan2.ar(sig * env, pan);
	Out.ar(0, sig * 1.4);
	Out.ar(~fxBus1, sig * 0.1);

}).add;

SynthDef(\perc1, {
	arg freq, atk = 0.001, dec = 0.1, pan, deltime;
	var sig, env;

	env = EnvGen.kr(Env.perc(atk, dec), doneAction: 2);
	sig = SinOsc.ar(freq + SinOsc.ar(300, 0, 300));
	sig = CombL.ar(sig, delaytime: deltime);

	Out.ar(~fxBus2, Pan2.ar(sig * env, pan) * 0.45);
}).add;

SynthDef(\perc2, {
	arg rate = 0, pan = 0, atk = 0.01, dec = 0.01;
    var sig, env, trig;

	env = EnvGen.kr(Env.perc(atk, dec), doneAction: 2);

    sig = WhiteNoise.ar * env;
	sig = BPF.ar(sig, TExpRand.kr(1000, 8000, Impulse.kr(0)), 0.1);

	Out.ar(~fxBus1, Pan2.ar(sig, pan) * 0.25);
	Out.ar(0, Pan2.ar(sig * env, pan) * 0.2);
}).add;

SynthDef(\wave, {
    arg amp = 0.2, fadeTime = 20, time = inf;
    var sig, env, pan, filfreq, fadeEnv;

    env = LFNoise1.kr(0.2).range(0.05, 1);
	fadeEnv = EnvGen.kr(Env.linen(fadeTime, time, 6), doneAction: 2);

    filfreq = LFNoise1.kr(0.05).range(300, 6000);

	pan = LFNoise1.kr(0.1).range(-1, 1);

    sig = PinkNoise.ar(amp);

    sig = RLPF.ar(sig, filfreq, 0.3);
	sig = RHPF.ar(sig, 300);

	Out.ar(0, Pan2.ar(sig * env * fadeEnv * 0.6, pan));
	Out.ar(~fxBus1, Pan2.ar(sig * env * fadeEnv * 0.1, pan));

}).add;

SynthDef(\sin, {
	arg atk, sus, rel, pan, freq, modfreq, modamp, filfreq;
	var sig, env;

	env = EnvGen.kr(Env.linen(atk, sus, rel, level: 1),doneAction: 2);

	modfreq = In.kr(~modfreqBus);

	sig = SinOsc.ar(freq + SinOsc.ar(modfreq, 0, modamp));
	sig = RLPF.ar(sig, filfreq);
	sig = Pan2.ar(sig * env, pan);
	Out.ar(~fxBus1, sig * 0.25);
	Out.ar(0, sig * 0.15);
}).add;

SynthDef(\FMPad, {
	arg dur, carfreq;
	var sig, trig, modfreq, index, env;

	trig = Dust.kr(800);

	env = EnvGen.kr(Env.asr(0.1, 1, 3), doneAction: 2);

	modfreq = TIRand.kr(1, 2) * carfreq;
	index = LFNoise1.kr(2).range(0, 30);

    sig = GrainFM.ar(2, trig, dur, carfreq, modfreq, index, mul: 0.2);
	sig = RLPF.ar(sig, 800, mul: 0.4);
	sig = sig * env;
	Out.ar(0, Pan2.ar(sig, 0) * 0.4);
	Out.ar(~fxBus3, Pan2.ar(sig, 0) * 0.4);
	Out.ar(~fxBus1, Pan2.ar(sig, SinOsc.kr(0.05)) * 0.3);
}).add;

SynthDef(\bass, {
	arg freq = 50, filfreq = 100;
	var sig, width, env, noise;

	env = EnvGen.kr(Env.linen(0.01, 0.5, 1.5), doneAction: 2);

	noise = BPF.ar(BrownNoise.ar(0.01), 700);

	sig = Pulse.ar(freq, 0.5);

	sig = DelayL.ar(sig, 0.5, SinOsc.ar(freq, mul: 0.01, add: 0.01));

	sig = RLPF.ar(sig, filfreq) + noise;

	Out.ar(0, Pan2.ar(sig * env * 0.4, 0));
	Out.ar(~fxBus1, Pan2.ar(sig * env * 0.6, 0));
}).add;

SynthDef(\lead, {
    arg freq = 440;
    var sig, env, pitchEnv, vibrato;

    env = EnvGen.kr(Env.perc(0.1, 1), doneAction: 2);

	pitchEnv = EnvGen.kr(Env([freq*0.8, freq], [0.05], 'exp'));

    sig = Saw.ar(pitchEnv, 0.3);
    sig = RLPF.ar(sig, 2500, 0.5);
	vibrato = SinOsc.kr(6, 0, 8);

    sig = Pan2.ar(sig * env * 0.5, 0);

    Out.ar(0, sig * 0.5);
	Out.ar(~fxBus1, sig * 0.5);
}).add;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// FX BUSES ////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

SynthDef(\reverbFX, {
    arg mix=0.5, room=0.9, damp=0.5;
    var sig;

    sig = In.ar(~fxBus1, 2);
    sig = FreeVerb.ar(sig, mix, room, damp);
    Out.ar(0, sig);
}).add;

SynthDef(\delayFX1, {
    arg time = 0.5;
    var sig;

    sig = In.ar(~fxBus2, 2);
	sig = DelayL.ar(sig, 3, time);
    Out.ar(0, sig);
}).add;

SynthDef(\delayFX2, {
    var sig, time;

	time = LFSaw.kr(0.05).range(1, 1.25);

    sig = In.ar(~fxBus3, 2);
	sig = DelayL.ar(sig, 3, time);
    Out.ar(0, sig);
}).add;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// CONTROL BUSES ///////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

SynthDef(\modfreqEnv, {
    arg start = 0, end = 10000, dur = 20;
    Out.kr(~modfreqBus, Line.kr(start, end, dur, doneAction: 2));
}).add;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// SEQUENCES ///////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

~whitenoise = Pbind(
	\instrument, \whitenoise,
	\dur, Prand([
		Pseq([1/8], 8),
		Pseq([2], 1),
		Pseq([1/16], 8),
		Pseq([1/32], 5),
		Pseq([1/32, 1/32, 1/32, 1/32, 1/16, 1/16, 1/16, 1/16, 1/8, 1/8], 1),
		Pseq([1, 2, 1/8, 1/8, 1, 1/16, 1/16, 1/16, 1/16, 1/2, 1/8, 1/8, 1/2, 2], 1),
		Pseq([1, 1/2, 1/8, 1/4, 1/4, 1/4], 2),
		Pseq([1/16, 1/16, 1/16, 1/16, 1/4, 1/4], 4),
		Pseq([1/6, 1/6, 1/6, 1, 1/4], 3)
	], inf),

	\pan, Prand([
		Pseq([-0.8, 0.8], 4),   // bounce L↔R four times
		Pseq([0], 8),           // center for 8 events
		Pseq([-1, -0.5, 0, 0.5, 1], 1), // quick sweep across
		Pseq([1,0.5, 0, -0.5, -1], 1),
		Pseq([1], 8),
		Pseq([-1], 8),
		Pseq([-1, 1, -0.75, 0.75, -0.5, 0.5, -0.25, 0.25], 2)
	], inf),
	\atk, 0,
	\sus, Pexprand(0.0005, 0.01),
	\rel, Prand([
		Pseq([0], 16),
		Pseq([0.001, 0.005, 0.01, 0.05, 0.1], 2),
		Pseq([0, 0, 0, 0.001, 0.001, 0, 0, 0.005, 0.005], 2),
	], inf)
);


~sin = Pbind(
	\instrument, \sin,
	\dur, Pseq([1/8], inf),

	\pan, Prand([
		Pseq([-0.8, 0.8], 4),
		Pseq([-1, -0.5, 0, 0.5, 1], 1),
		Pseq([1,0.5, 0, -0.5, -1], 1),
		Pseq([-1, 1, -0.75, 0.75, -0.5, 0.5, -0.25, 0.25], 2)
	], inf),

	\freq, Pseq([
		Pseq([196, 250, 300, 330, 370, 196, 300, 500], 8),
		Pseq([294, 370, 440, 554, 740, 294, 440, 1480], 8),
		Pseq([440, 554, 660, 740, 988, 440, 494, 1319], 8),
		Pseq([330, 392, 494, 740, 660, 784, 1175, 1319], 8)

	], inf),

	\modfreq, Pfunc({ ~modfreqVal }),

	\modamp, Pfunc({ ~modampVal }),

	\filfreq, Pfunc({ ~filfreqVal }),


	\atk, 0.1,
	\sus, 0.0005,
	\rel, 0.01
);

~fmPad = Pbind(
		\instrument, \FMPad,
		\dur, Pseq([4], inf),
		\carfreq, Pseq([
			[98, 196, 250, 300, 330], [98, 196, 250, 300, 330],
			[147, 294, 370, 440, 554], [147, 294, 370, 440, 554],
			[220, 440, 554, 660, 740], [220, 440, 554, 660, 740],
			[115, 330, 392, 494, 740], [115, 330, 392, 494, 740],
		], inf)
);

~bass = Pbind(
		\instrument, \bass,
		\dur, Prand([
			Pseq([2, 1.5, 2], 1),
			Pseq([2, 1.5, 6], 1)
		], inf),
		\freq, Prand([
			Pseq([82, 62, 73], 1),
			Pseq([62, 41, 110], 1),
			Pseq([98, 82, 123], 1),
			Pseq([98, 147, 123], 1)
		], inf)
);

~lead = Pbind(
    \instrument, \lead,
    \dur, Pseq([1, 1, 1, 1, 1, 1, 1, 1, 16], inf),
    \freq, Pseq([370, 392, 494, 587, 370, 392, 740, 660, 494], inf),
    \pan, Pwhite(-0.5,0.5),
);

~perc1 = Pbind(
	\instrument, \perc1,
	\dur, Prand([
		Pseq([1/4], 3),
		Pseq([2], 1),
		Pseq([3], 1),
		Pseq([1/2], 1),
		Pseq([1/6], 2),
		Pseq([1/8, 1/8, 1/4, 1/8], 2)
	], inf),
	\deltime, Pwhite(0.001, 0.1),
	\freq, Pwhite(5000, 10000),
	\dec, Pwhite(0.001, 0.1),
	\pan, Pwhite(-1, 1)
);


~perc2 = Pbind(
	\instrument, \perc2,
	\pan, Pwhite(-1,1),
	\dur, Prand([0.05, 0.1, 0.2, 0.01, 0.005, 1/4, 1, 2], inf),
	\atk, 0.01,
	\dec, 0.01,
);
}.value
)


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// PLAY CONTROLS ///////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

//FX BUSES//
(
~fx1 = Synth(\reverbFX); //instantiates FX; DO THIS FIRST
~fx2 = Synth(\delayFX1);
~fx3 = Synth(\delayFX2);
)

//PERCUSSION//
~whitenoise = ~whitenoise.play(t);      //white noise percussion
~perc1 = ~perc1.play(t);                //glassy percussion
~perc2 = ~perc2.play(t);                //random reverb percussion
~wave = Synth(\wave, [\time, inf]);     //pink noise wave

//MAIN SYNTHS//
(
~modampVal = 1000;                      //adds sin arpeggio, schedules fm pad 64 beats later, schedules bass
~modfreqVal = 10000;                    //96 beats later
~filfreqVal = 5000;
~sin = ~sin.play(t);
t.sched(64, { ~fmPad = ~fmPad.play(t); });
t.sched(96, { ~bass = ~bass.play(t); });
t.sched(32, { ~lead = ~lead.play(t); });
)

//FM ENVELOPES//
(
var fmEnv = Synth(\modfreqEnv); //FM envelope going down; changes timbre of sin arp
fmEnv.set(\start, 10000);
fmEnv.set(\end, 3000);
fmEnv.set(\dur, 10);
)

(
var fmEnv = Synth(\modfreqEnv); //FM envelope going up
fmEnv.set(\start, 3000);
fmEnv.set(\end, 10000);
fmEnv.set(\dur, 10);
)


//STOP MESSAGES//
~whitenoise.stop;
~perc1.stop;
~perc2.stop;

~bass.stop;
~lead.stop;
~fmPad.stop;
~sin.stop;

~wave.set(\time, 1); //stop wave sounds; this should make waves fade out, if not use ~wave.free//
~wave.free;






