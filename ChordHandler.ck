//    File: ChordHandler.ck
//    Author: Juan Riera Gomez
//    
//    This file contains the ChordHandler class, which inherits from NoteSetHandler
//    to store chords.

public class ChordHandler extends NoteSetHandler{
    

    
//        Function that obtains the notes of the currently selected
//        chords.
//
//        Outs: an array of floats with the midi notes of the chords.    
    
    fun float[] getCurrentChordNotes(){
        if(isKnownNoteSet(currentSet)==0){
            return NULL;
        } else {
           
            float chordNotes[noteTables[currentSet].cap()];
            for(0=>int i ; i<noteTables[currentSet].cap() ; i++){
                noteTables[currentSet][i]+currentTranspose => chordNotes[i];
            }
            return chordNotes;
        }
    } 
}
