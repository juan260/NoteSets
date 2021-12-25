 
//    File: NoteSetHandler.ck
//    Author: Juan Riera Gomez
    
//    Contains the bastract class NoteSetHandler, which
//    is designed to contain note sets, so that
//    both the Chord Handler and Scale Handler can inherit from it.


// ABSTRACT CLASS
public class NoteSetHandler{
    
    127 => int maxNoteTableSize; // MACRO: maximum table size
    
    127 => int maxNoteSets;       // MACRO: maximum number of note sets
    
    float noteTables[0][maxNoteTableSize]; // Note set 2D table (indexed)
    string knownNotes[maxNoteSets]; // Table with the dictionary entries of the note set table
    0 => int currentKnownNotes; // Stores the number of entries in the table
    string currentSet; // Current note set in use
    0 => int currentTranspose; // Transposition from the standard note (C). For example,
                                // if we are in D, this would be 2 (2 semitones Higher from C)
    
    initNoteSetTable() @=> noteTables; // Initialize the table note
    
   // Open the configuration file
    FileIO file;
    if(file.open(me.dir() + "/noteTranspositions.conf", FileIO.READ)==false){
        <<< "noteTranspositions.conf not found!!">>>;
        Machine.crash();
    }
    int roots[0];
    string knownRoots[0];
    int knownRootsCount;
    int ival;
    string sval;
    // Read "noteName"
    file => sval;
    // Read "Transposition"
    file => sval;
    while(true)
    {
         file => sval;
        if(file.eof()) break;
            
         file => ival;
        if(file.eof()) break;
            
         ival => roots[Std.itoa(sval.charAt(0))];
         Std.itoa(sval.charAt(0)) => knownRoots[Std.itoa(knownRootsCount)];
         knownRootsCount++;
         
    }
    file.close();
    
//       Changes the current note set in use.
//        
//        Ins: string with the new desired note set
//        Outs: 1 if success, -1 if unknown note set (fail)
    
    fun int changeNoteSet(string newSet){
        <<<"ChangeAttempt", newSet >>>;
        for(0=>int i;i<currentKnownNotes;i++){
            if(knownNotes[i]==newSet){
                newSet => currentSet;
                <<< "Set Changed", newSet >>>;
                return 1;
            }
        }
        return -1;
    }
    
     
//        Function to change the root and set (C major, or D minor).
//        
//        Ins: String with the root note, and another string with 
//            the quality (for example "C", "mayor")
//        Outs: 1 success, -1 fail
    
    fun int changeNoteSet(string root, string name){
        getTranspositionFromNoteName(root) => int newTransp;
        if(newTransp < -12)
            return -1;
        newTransp => currentTranspose;
        return changeNoteSet(name);
    }
    
    
//        Function that checks if there is no set selected
//        
//        Outs: 1 yes, 0 no
    
    fun int inSilence(){
        return currentSet == "Silence";
    }
    
     
//        Function that outputs the positive modulo of two integers.
//        Example     5 % 4 = 1
//                    7 % 4 = 3
//                    -1 % 3 = 2 (standard ChucK would give -1)
//        Ins: the integers
//        Outs: positive modulo (integer)
    
    fun int positiveModulo(int a, int m){
        return (a%m+m)%m;
    }
    
    
//        Function that returns a initialized note set table,
//        The only set by default is "Silence" which means that no sound
//        should be produced.
    
    fun float[][] initNoteSetTable() {
        float auxiliarTable[maxNoteTableSize];
        for (0 => int i; i<maxNoteTableSize; i++){
            -10000000 => auxiliarTable[i];
        }
        auxiliarTable @=> noteTables["Silence"];
        "Silence" => currentSet;
        0 => currentTranspose;
        
        currentSet => knownNotes[currentKnownNotes];
        currentKnownNotes++;

        return noteTables;
    }   

    
//        Responds to the question: Is this a know set name?
//        Ins: the name
//        Outs: 1 yes, 0 no
    
    fun int isKnownNoteSet(string name){
        for(0 => int i; i<currentKnownNotes; i++){
            if(knownNotes[i] == name){
                
                return 1;
            }
        }
        return 0;
    }
    

//        "Private function": Adds the name of a noteset. This function should not
//        generally be called by the user.
//        Ins: set name
//        Outs: 1 success, 0 the set was already in the table, -1 fail,
//        maybe because maximum number of sets has been reached. In this case 
//        the last set would be replaced by the new one.

    fun int addNoteSetName(string name){
        
        name => knownNotes[currentKnownNotes];
        if(isKnownNoteSet(name)){
            <<< name, "already exists!">>>;
            return 0;
           
        }
        if(currentKnownNotes<maxNoteSets-1){
                
                currentKnownNotes++;
        }else{
            <<<"Maximum number of scales reached!">>>;
            return -1;
        }
        return 1;
        
    }
    

//        Adds a new set to the set table
//        Ins: string with the name, and the midi notes as a float array
 //       Outs: the note set table.

    fun float[][] addSetToTable(string name, float notes[]){
        <<< "Adding note set", name>>>;
        notes @=> noteTables[name];
        addNoteSetName(name);
        return noteTables;
    }
    

//        Obtains the transposition associated with the name of a note.
//        Ins: the name of the note (por ejemplo: C, C#, Ab, Abb, Abbb...)
//        Outs: the associated transposition or -100000 if error.

    fun int getTranspositionFromNoteName(string note){
        if(note.charAt(0) > 'a')
            note.setCharAt(0, note.charAt(0)+'a'-'A');
        for(0=>int i; i<knownRootsCount; i++){
            if(knownRoots[Std.itoa(i)]==Std.itoa(note.charAt(0))){
                0 => int flatsSharps;
                
                for(1=> int j;j<note.length();j++){
                    if(note.charAt(j) == '#')
                        flatsSharps++;
                    if(note.charAt(j) == 'b')
                        flatsSharps--;
                }
                return roots[Std.itoa(note.charAt(0))]+flatsSharps; 
            }
        }
        
        <<< "Invalid note name", note>>>;
        return -100000;       
    }
    
}