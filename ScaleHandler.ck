//    File: ScaleHandler.ck
//    Author: Juan Riera Gomez
    
//    Contains the ScaleHandler class, which inherits from NoteSetHandler.
//    It manages the scales. It can also return the associated note with a displacement (see wiki)
//    in a continuous way that "makes sense" musically, instead of just a linear interpolation
//    or  a discreet function.


public class ScaleHandler extends  NoteSetHandler{ 
            
    4 => int roundNoteWeight; // MACRO that controls the note rounding.
                              // The higher the value, the closer the function would be
                              // to a step function.
    
    
//        Special note rounding so that the notes "between" notes are continous.
//        but in an exponential way, like an s curve.
//        Ins: base note, closest note, distance between notes
//            in the scale that we are in
//        Outs: special rounding
    
    fun float specialRound(float startingPoint, float target, float distance){       
        return Math.pow(2*(startingPoint-target)/distance, 
        2*roundNoteWeight+1)*distance/2 + target;

    }    

    
//        Approximates the Midi in note (displacement) to the closest one in
//        the scale, with special rounding for non integer values.
//        Ins: midi note as a float
//        Outs: rounded midi note in the scale
    
    fun float getRoundedMidi(float midiNote){
        
        midiNote => float original;
        Math.max(0, midiNote) => midiNote; 
        Math.min(maxNoteTableSize-2, midiNote) => midiNote;
        Std.ftoi(Math.round(midiNote)) => int midiNoteIndex;
        noteTables[currentSet][midiNoteIndex]+currentTranspose => midiNote;
        
        1.0 => float distance;
        midiNote => float startingPoint;
        original-Math.floor(original) => float decimalPart;
         
        if(original > Math.round(original)){
            noteTables[currentSet][midiNoteIndex+1]+currentTranspose-midiNote => 
            distance; 
            midiNote + decimalPart*distance => startingPoint;
       }
        else {
            midiNote-noteTables[currentSet][midiNoteIndex-1]-currentTranspose => 
            distance;    
            midiNote - (1-decimalPart)*distance => startingPoint;
          
        }
        return specialRound(startingPoint, midiNote, distance);
    }

       
     
//        Rounding of the frequency to midi. Converts the frequency to
//        standard midi and calls getRoundedFreqFromMidi.
//        Ins: the frequency
//        Outs: rounded frequency in the scale
    
    fun float getRoundedFreq(float freq){
                
                Std.ftom(freq) => float midiNote;
                return getRoundedFreqFromMidi(midiNote);
            }
    
    
//        Redondeo del midi de entrada dentro de la escala 
//        de getRoundedMidi, pero convirtiendolo a frecuencia al final.
//        Ins: nota midi
//        Salida: la frecuencia con el redondeado especial dentro de la escala.
    
    fun float getRoundedFreqFromMidi(float midiNote){
        
        return Std.mtof(getRoundedMidi(midiNote));
    }
        
    
    
//        Generates the note table
//        from the intervals of the input. 
        
//        Ins: array of intervals that compose the scale.
//        Outs: scale table.
    
    fun float[] genScaleTable(float scale[]) {
        float scaleTable[maxNoteTableSize];
        int startingMidiNote;
        float currentMidiNote;
        int i;
        60 => startingMidiNote;
        60 => i;
        startingMidiNote => currentMidiNote;
        currentMidiNote => scaleTable[i];
        // Fill the table from middle upward
        while(i<maxNoteTableSize-1){
            i++; 
            scale[positiveModulo((i-startingMidiNote-1),scale.cap())] +=> 
            currentMidiNote;
            currentMidiNote => scaleTable[i];
            
            if(currentMidiNote>126)
                break;
            
        }
        // Finish fillinf the table
        while(i<maxNoteTableSize-1){
            i++;
            126 => scaleTable[i];
        }
        // Fill the table middle downwards
        startingMidiNote => i;
        startingMidiNote => currentMidiNote;
        while(i>0){
            i--;
            scale[positiveModulo((i-startingMidiNote),scale.cap())] -=> 
            currentMidiNote;
            
            currentMidiNote => scaleTable[i];
            
            if(currentMidiNote<0)
                break;
            
        }
        // Finish filling
        while(i>0){
            i--;
            0 => scaleTable[i];
        }
        return scaleTable;
        
        
        }
     
//        Adds a new scale to the table. 
        
//        Ins: name of the scale and an array with the intervals.
//        
//        Outs: the scale table.
   
    fun float[][] addSetToTable(string name, float notes[]){
        <<< "Adding scale", name>>>;
        genScaleTable(notes) @=> noteTables[name];
        addNoteSetName(name);
        return noteTables;
    }
    
     
//        Adds a new scale to the scale table, from the midi notes. 
//        Recibe el nombre de la escala
//        y un array con una repeticion de la misma, se calculan los intervalos
//        y se le pasan a addSetToTable
//        para generar la escala completa, guardarla en la tabla de escalas.
//        
//        Ins: recieves one scale name and one repetition of it.
//    
//        Outs: the complete scale table.
//   
        
    fun float[][] addSetToTableFromMidi(string name, float midiNotes[]){
        float scale[midiNotes.cap()-1];
        for(0=>int i; i<scale.cap();i++){
            midiNotes[i+1]-midiNotes[i] => scale[i];
        }
        return addSetToTable(name, scale);
    }
}