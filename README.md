# NoteSets

NoteSets is a library for Chuck, designed to add functionality to support scales
and chords in an abstract way. It is part of two bigger projects:

* [Loosy Synth](https://www.github.com/juan260/LoosySynth/) is a music synthesizer controlled by OSC protocol with a special interface designed to be controlled from an external device, such as a mobile phone or a VR headset.
* [Loosy](https://www.github.com/juan260/Loosy/) is the project that originated the other two, it uses a slight variation of this library to be controlled from the Hololens 2 headset.

I decided to make NoteSets a library thinking that someone could find it useful for their projects. Please contact me if you do, I would love to see what may come out of this!

## General functionality

Both scales and chords are abstracted into a higher class, called note sets. Both chords and scales are just note sets: 

* **Chords** are a set of finite notes in this library. For example a major chord is stored as the notes C, E and G, and is then transposed accordingly to any other root. When the user tells the library about a new chord, it can be expressed in any root, the important thing are the intervals between the notes.
* **Scales** on the other hand, scales are considered as a set of notes that repeat accross the whole MIDI piano roll, so a major scale set is stored as the whole C major scale repeated as many times as possible accross the whole piano roll (all possible MIDI notes) and transposed accordingly when needed. When the user needs to tell the library about a new scale, only one full repetition is needed. For example to tell the library about the major scale, one could write D, E, F#, G, A, B, C# and D, for a chromatic scale, only two notes are needed (like E and F) and that would be understood as a full repetition.



