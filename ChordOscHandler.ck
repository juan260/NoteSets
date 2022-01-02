//    File: ChordOscHandler.ck
//    Author: Juan Riera Gomez
    
//    File containing the ChordOscHandler class
//    that manages the different chord voices,
//    what note is played by each oscillator, their amplitudes etc.
//    The chords come out through a Low Pass filter that can also be accessed and
//    edited.

//    It contains the MACRO maxNotes that changes the maximum number
//    of simultaneous notes. 


public class ChordOscHandler{

    10 => int maxNotes; // MACRO: Maximum number of notes
    1 => int currentlySoundingNotes; // Number of currently sounding notes
    UnisonVoice oscillators[maxNotes]; // Array of oscillators
    //SawOsc oscillators[maxNotes];
    LPF filter; // Low pass filter
    
    float gain; // Overall gain
    
    // We connect all of the oscillators to the filter
    for(0 => int i; i<maxNotes;i++){
        oscillators[i].connect(filter);
        //oscillators[i] => filter;
    }
    
    // Create the chord handler
    ChordHandler chordHandler;
    // Mute the oscillators
    setGain(0.0);
    
    
//        Function that sets the number of notes (oscillators) currently sounding. 
//        
//        Ins: the number of notes.
//        Outs: the new number of notes playing, 
//            if it doesn't match the input means that the maximum number of notes were already playing, 
//            or that the input was lower than 1. 
    
    fun int setCurrentlySoundingNotes(int n){
        Std.ftoi(Math.min(Math.max(1,n), maxNotes)) => currentlySoundingNotes;
        setGain(gain);
        return currentlySoundingNotes;
    }
    
     
//	  Functioin to change the maximum number of notes that can be playing at the same
//        time in a chord. This will change the length of the array of oscillators.
//        
//        Ins: maximum number of notes.
//        Outs: the maximum number of notes that can sound in a chord.

    fun int setMaxNotes(int n){
        
        UnisonVoice newOscillators[n];
        int i;
        for(0=>i;i<maxNotes;i++){
               oscillators[i] @=> newOscillators[i];
        }
        for(;i<n;i++){
                //createNewOsc() @=> newOscillators[i]; 
                newOscillators[i].connect(filter);
                //newOscillators[i] => filter;
        }
        newOscillators @=> oscillators; 
        Std.ftoi(Math.max(1.0,n)) => maxNotes;
        return maxNotes;
    }
    
     
//        Connect this module to the next one in chuck. For example, if we want the chord
//        to then go through a filter, call this function with that filter as an argument.
//        Ins: the module we wan to connect with.
    
    fun void connect(UGen output){
        filter => output;
    }
    
    
//        Funcion to change the general gain of the oscillators.
//        It 'splits' the gain among them.
//        Ins: the new gain.
    
    fun void setGain(float g){
        0.7 * g => g;
        if(inSilence())
            0.0=>g;
        int i;
        for(0 =>i; i<currentlySoundingNotes;i++){
           g/currentlySoundingNotes => oscillators[i].gain;
        }
        while(i<maxNotes){
            0.0 => oscillators[i].gain;
            i++;
        }
        g => gain;
    }
        
   
     
//        Function that changes the cutoff frequency of the filter
//        Ins: the cutoff frequency
    
    fun void setFilterCutoff(float cutoff){
        if(cutoff <7000)
            cutoff => filter.freq;
    }
    
    
//        Function that checks if the chord is playing or not.
//        Outs: 1 if the chord is playing or 0 if not.

    fun int inSilence(){
        return chordHandler.inSilence();
    }
    
    
//        Function to change the chord
//        Ins: root of the note, quality of the note.
//        Outs: 0 fail, 1 success

    fun int changeChord(string root, string quality){
        
        chordHandler.changeNoteSet(root, quality);
        chordHandler.getCurrentChordNotes()@=> float newChord[];
        if(newChord==NULL)
            return 0;
        int i;
        for(0=>i; i<Math.min(newChord.cap(), maxNotes);i++){
            
            Std.mtof(newChord[i])/2 => oscillators[i].freq;
        }
        
        setCurrentlySoundingNotes(Std.ftoi(Math.min(newChord.cap(), maxNotes)));
        return 1;
    }
    
//        Auxiliar private function to create a new chord.
//        Outs:  a new silent oscillator.
    
    fun UnisonVoice createNewOsc(){
        UnisonVoice osc;
        0.0 => osc.gain;
        return osc;
    }
    
    
//        Function to add a new chord to the table.
//        Ins: notes of the chord, and name of the chord (major, minor...)
//        Outs: the table of chords.
    
    fun float[][] addChordToTable(float notes[], string name){
       if(notes.cap()>maxNotes){
           setMaxNotes(notes.cap());
       }
        return chordHandler.addSetToTable(name,notes);
    }
} 

//         Abstract class that expresses a chord voice

private class ChordVoice{
    fun void freq(float f){}
    fun void gain(float g){}
    fun void connect(UGen out){}
}

//           This voice uses other voices

private class UnisonVoice extends ChordVoice{
    BPF eqBand1;
    
    SawOsc saw => LPF sawFilter => eqBand1;
    BowedVoice bowed;
    MoogVoice moog;
    bowed.connect(eqBand1);
    moog.connect(eqBand1);

    300 => sawFilter.freq;
    90 => eqBand1.freq;
    2.0 => eqBand1.gain;
    0.3 => eqBand1.Q;

    fun void freq(float f){
        f => saw.freq;
        f => bowed.freq;
        f=> moog.freq;
    }

    fun void gain(float g){
        g/4 => saw.gain;
       g/3 => bowed.gain;
       g/3 => moog.gain;

    }
    fun void connect(UGen out){
        eqBand1 => out;
    }
}


//        Sawtooth voice

private class SawVoice extends ChordVoice{
    SawOsc oscillator;
    fun void freq(float f){
        f => oscillator.freq;
    }
    fun void gain(float g){
        g => oscillator.gain;
    }
    fun void connect(UGen out){
        oscillator => out;
    }
}

// UNUSED clarinet voice
private class ClarinetVoice extends ChordVoice{
    Clarinet oscillator;
    Std.rand2f(0.4, 0.7)=>oscillator.vibratoGain;

    Std.rand2f(6,10)=>oscillator.vibratoFreq;

    1.0=>oscillator.gain;

    220 => oscillator.freq;
    0.9=>oscillator.noteOn;
    0.9=>oscillator.startBlowing;

    fun void freq(float f){
        f => oscillator.freq;
    }
    fun void gain(float g){
        g => oscillator.gain;
    }
    fun void connect(UGen out){
        oscillator => out;
    }
}


//       Bowed voice
private class BowedVoice extends ChordVoice{
    Bowed oscillator;
   Std.rand2f(0.01, 0.07)=>oscillator.vibratoGain;

        Std.rand2f(2,8)=>oscillator.vibratoFreq;
        220=>oscillator.freq;
        0.9 => oscillator.gain;
                
                
        0.8=>oscillator.noteOn;
        0.8=>oscillator.startBowing;

        1=>oscillator.volume;
    
    fun void freq(float f){
        f => oscillator.freq;
    }
    fun void gain(float g){
        g => oscillator.gain;
    }
    fun void connect(UGen out){
        oscillator => out;
    }
}


//       Moog voice
private class MoogVoice extends ChordVoice{
    Moog oscillator;
    0 => oscillator.filterQ;
    Std.rand2f(0.01, 0.05) => oscillator.lfoDepth;
    Std.rand2f(0,3) => oscillator.lfoSpeed;
    1 => oscillator.volume;
    1 => oscillator.noteOn;
    440 => oscillator.freq;
    
    fun void freq(float f){
        f*2 => oscillator.freq;
    }
    fun void gain(float g){
        g => oscillator.gain;
    }
    fun void connect(UGen out){
        oscillator => out;
    }
}

//UNUSED Saxofony voice
private class SaxofonyVoice extends ChordVoice{
    Saxofony oscillator;
    Std.rand2f(0.4, 0.8)=>oscillator.vibratoGain;

        Std.rand2f(6,10)=>oscillator.vibratoFreq;

        1.0=>oscillator.gain;

        220 => oscillator.freq;
        1=> oscillator.startBlowing;
    
    fun void freq(float f){
        f => oscillator.freq;
    }
    fun void gain(float g){
        g => oscillator.gain;
    }
    fun void connect(UGen out){
        oscillator => out;
    }
}
