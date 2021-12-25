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

    30 => int maxNotes; // MACRO: Maximum number of notes
    1 => int currentlySoundingNotes; // Number of currently sounding notes
    SawOsc oscillators[maxNotes]; // Array of oscillators
    LPF filter; // Low pass filter
    float gain; // Overall gain
    
    // We connect all of the oscillators to the filter
    for(0 => int i; i<maxNotes;i++){
        oscillators[i] => filter;
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
        
        SawOsc @ newOscillators[n];
        int i;
        for(0=>i;i<maxNotes;i++){
               oscillators[i] @=> newOscillators[i];
        }
        for(;i<n;i++){
               createNewOsc() @=> newOscillators[i]; 
                newOscillators[i] => filter;
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
            <<< newChord[i]>>>;
            Std.mtof(newChord[i]) => oscillators[i].freq;
        }
        
        setCurrentlySoundingNotes(Std.ftoi(Math.min(newChord.cap(), maxNotes));
        return 1;
    }
    
//        Auxiliar private function to create a new chord.
//        Outs:  a new silent oscillator.
    
    fun SawOsc createNewOsc(){
        SawOsc osc;
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
