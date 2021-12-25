//    File: main.ck
//    Author: Juan Riera Gomez
    
//    This file loads all of the necessary files.
    


// Create an array with all the necessary files in order
["NoteSetHandler", "ChordHandler", "ScaleHandler", "ChordOscHandler"] @=> string libs[];

// Open the files
for(0 => int i; i< libs.cap(); i++){
    
    // If one is not found, we fail.
    if(Machine.add(me.dir()+"/"+libs[i]+".ck")==0){
        // Inform the user about it.
        <<< libs[i] + " not found or already added!" >>>;
    }
}
        

