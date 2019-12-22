   //
//  ViewController.swift
//  miniDBFMDB
//
//  Created by Magnus Kruschwitz on 11.11.19.
//  Copyright © 2019 Magnus Kruschwitz. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var textFieldChristianName: NSTextField!
    @IBOutlet weak var textFieldSurName: NSTextField!
    @IBOutlet weak var textFieldStreet: NSTextField!
    @IBOutlet weak var textFieldZipCode: NSTextField!
    @IBOutlet weak var textFieldCity: NSTextField!
    @IBOutlet weak var textFieldTelefone: NSTextField!
    @IBOutlet weak var textFieldSearch: NSTextField!
    @IBOutlet weak var labelNumber: NSTextField!
    
    var dokumentePfad: String!
    var dbName: String!
    var dbPath: String!
    var textFieldStack: [String: NSTextField]!
    var myDB: FMDatabase!

    override func viewDidLoad() {
        super.viewDidLoad()

        if !checkDB() {
            meineMeldung(meinText: "Die Datenkbankdatei ist nicht vorhanden.")
            NSApplication.shared.terminate(self)
        }
        // Do any additional setup after loading the view.
        
        //myDB = FMDatabase(path: self.dbPath)
        
        textFieldStack = [
            "Vorname"      : textFieldChristianName,
            "Nachname"     : textFieldSurName,
            "Straße"       : textFieldStreet,
            "Postleitzahl" : textFieldZipCode,
            "Ort"          : textFieldCity,
            "Telefon"      : textFieldTelefone
        ]
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func fctBtnCloseClicked(_ sender: AnyObject){
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func btnNewClicked(_ sender: AnyObject){
        
        if myDB.open() ==  true{
            
            var errorMessage = ""
            
            for field in textFieldStack {
                if field.value.stringValue == "" && field.key != "Telefon"{
                    errorMessage += "Fehlde Eingabe in \(field.key) \n"
                }
            }
            
            if(errorMessage == ""){
                let sqlQuery = "INSERT INTO adressen (avorname, anachname, astrasse, aort, aplz, atelefon) VALUES ('\(textFieldChristianName.stringValue)', '\(textFieldSurName.stringValue)','\(textFieldStreet.stringValue)','\(textFieldCity.stringValue)', '\(textFieldZipCode.stringValue)','\(textFieldTelefone.stringValue)')"
                
                //let sqlQuery = "INSERT INTO adressen (avorname, anachname, astrasse, aplz, aort) VALUES ('Erna', 'Strobelt', 'Birnenplatz 1', '56789', 'Bullerbue');"
                
                let bReturn = myDB.executeUpdate(sqlQuery, withArgumentsIn: [])
                                
                if bReturn {
                    meineMeldung(meinText: "Datensatz wurde erfolgreich hinzugefügt.")
                    
                    self.fctClearInputs()
                }
                else {
                    meineMeldung(meinText: "Die Daten konnten nicht eingefügt werden.")
                }
            }
            else{
                meineMeldung(meinText: errorMessage)
            }
            
            myDB.close()
        }
        else{
            meineMeldung(meinText: "Fehler: \(myDB.lastErrorMessage())")
        }
    }
    
    @IBAction func btnSearchClicked(_ sender: AnyObject){
        
        if myDB.open() ==  true{
            let sqlQuery = "SELECT * FROM adressen WHERE anachname = '\(textFieldSearch.stringValue)'"
            let ergebnisMenge: FMResultSet = myDB.executeQuery(sqlQuery, withArgumentsIn: [])!
            
            
            if ergebnisMenge.next() == true{
                labelNumber.stringValue            = ergebnisMenge.string(forColumn: "anummer")!
                textFieldChristianName.stringValue = ergebnisMenge.string(forColumn: "avorname")!
                textFieldSurName.stringValue       = ergebnisMenge.string(forColumn: "anachname")!
                textFieldStreet.stringValue        = ergebnisMenge.string(forColumn: "astrasse")!
                textFieldCity.stringValue          = ergebnisMenge.string(forColumn: "aort")!
                textFieldZipCode.stringValue       = ergebnisMenge.string(forColumn: "aplz")!
                
                if(ergebnisMenge.string(forColumn: "atelefon") != nil){
                    textFieldTelefone.stringValue = ergebnisMenge.string(forColumn: "atelefon")!
                }
                
                textFieldSearch.stringValue = ""
            }
            else{
                meineMeldung(meinText: "Kein Eintrag für " + textFieldSearch.stringValue + " gefunden")
            }
            
            myDB.close()
        }
        else{
            meineMeldung(meinText: "Fehler: \(myDB.lastErrorMessage())")
        }
    }
    
    @IBAction func btnDeleteClicked(_ sender: AnyObject){
        if labelNumber.stringValue != "" {
            
            if myDB.open() ==  true{
                let sqlQuery = "DELETE FROM adressen WHERE anummer = '\(labelNumber.stringValue)'"
                let bReturn = myDB.executeUpdate(sqlQuery, withArgumentsIn: [])
                                
                if bReturn {
                    meineMeldung(meinText: "Datensatz wurde erfolgreich gelöscht.")
                    
                    self.fctClearInputs()
                }
                else {
                    meineMeldung(meinText: "Die Daten konnten nicht gelöscht werden.")
                }
                

                myDB.close()
            }
            else{
                meineMeldung(meinText: "Fehler: \(myDB.lastErrorMessage())")
            }
        }
    }
    
    @IBAction func btnUpdateClicked(_ sender: AnyObject){
        if labelNumber.stringValue != "" {
            
            if myDB.open() ==  true{
                
                var errorMessage = ""
                
                for field in textFieldStack {
                    if field.value.stringValue == "" && field.key != "Telefon"{
                        errorMessage += "Fehlde Eingabe in \(field.key) \n"
                    }
                }
                
                if errorMessage == ""{
                                
                    let sqlQuery = "UPDATE adressen SET avorname = '\(textFieldChristianName.stringValue)', anachname = '\(textFieldSurName.stringValue)', astrasse = '\(textFieldStreet.stringValue)', aort = '\(textFieldCity.stringValue)', aplz = '\(textFieldZipCode.stringValue)', atelefon = '\(textFieldTelefone.stringValue)' WHERE anummer = '\(labelNumber.stringValue)'"
                    let bReturn = myDB.executeUpdate(sqlQuery, withArgumentsIn: [])
                                    
                    if bReturn {
                        meineMeldung(meinText: "Datensatz wurde erfolgreich geupdatet.")
                        
                        self.fctClearInputs()
                    }
                    else {
                        meineMeldung(meinText: "Die Daten konnten nicht geupdatet werden.")
                    }
                }
                else{
                    meineMeldung(meinText: errorMessage)
                }

                myDB.close()
            }
            else{
                meineMeldung(meinText: "Fehler: \(myDB.lastErrorMessage())")
            }
        }
    }
    
    func meineMeldung(meinText: String) {
        let meineMeldung: NSAlert = NSAlert()
        meineMeldung.messageText = "Hinweis"
        meineMeldung.informativeText = meinText
        meineMeldung.runModal()
    }
    
    func loadDB() -> Bool {
        if !FileManager.default.fileExists(atPath: self.dbPath){
            print("Datenbank nicht vorhanden, wird angelegt.")
            self.myDB = FMDatabase(path: self.dbPath)
            if self.myDB.open(){
                var sqlQuery = "CREATE TABLE adressen(aNummer INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, avorname TEXT NOT NULL, anachname TEXT NOT NULL, astrasse TEXT NOT NULL, aplz TEXT NOT NULL, aort TEXT NOT NULL, atelefon TEXT)"
                
                do{
                    try self.myDB.executeUpdate(sqlQuery, values: nil)
                    print("geöffnet")
                    print("Installiere Defaultdaten.")
                    sqlQuery = "INSERT INTO adressen (avorname, anachname, astrasse, aplz, aort) VALUES ('Erwin', 'Mueller', 'Hasenweg 16', '12345', 'Hasenhausen')"
                    try self.myDB.executeUpdate(sqlQuery, values: nil)
                    sqlQuery = "INSERT INTO adressen (avorname, anachname, astrasse, aplz, aort) VALUES ('Erna', 'Strobelt', 'Birnenplatz 1', '56789', 'Bullerbue')"
                    try self.myDB.executeUpdate(sqlQuery, values: nil)
                    
                    self.myDB.close()
                    return true
                }
                catch{
                    print(error.localizedDescription)
                }
            }
            else{
                print("Datenbank konnte nicht geöffnet werden.")
                NSApplication.shared.terminate(self)
            }
            return false
        }
        else{
            self.myDB = FMDatabase(path: self.dbPath)
            return true
        }
        /*
         
        let myOpenPanel = NSOpenPanel()
        myOpenPanel.title = "Öffnen"
        myOpenPanel.prompt = "Öffnen"
        myOpenPanel.allowedFileTypes = ["db"]
        
        if myOpenPanel.runModal() == NSApplication.ModalResponse.OK {
            self.dbName = myOpenPanel.url?.path
            return true
        }
        else{
            return false
        }
        
        */
    }
        
    
    func checkDB() -> Bool {
        self.dokumentePfad = NSSearchPathForDirectoriesInDomains (.documentDirectory, .userDomainMask, true)[0] as String
        //self.dbName = "/Users/\(NSUserName())/Development/DBSample/minidb.db"
        self.dbName        = "minidb.db"
        self.dbPath        = "\(String(self.dokumentePfad))/\(String(self.dbName))"
        
        if loadDB(){
            return true
        }
        else {
            return false
        }
    }
    
    func fctClearInputs(){
        for field in textFieldStack {
            field.value.stringValue = ""
        }
        labelNumber.stringValue = ""
        textFieldSearch.stringValue = ""
    }
}

