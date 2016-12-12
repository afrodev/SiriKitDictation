//
//  ViewController.swift
//  SingPortoSeguro
//
//  Created by Humberto Vieira on 10/14/16.
//  Copyright © 2016 Humberto Vieira. All rights reserved.
//

import UIKit
import Speech


class SpeechViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var textViewWords: UITextView!
    @IBOutlet weak var buttonRecord: UIButton!
    @IBOutlet weak var labelScore: UILabel!
    
    // Initialize Speech Recognizer in Portuguese
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "pt-BR"))!
    
    // Get Request Audio Buffer Recognition
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    // Declare a thread that cares Speeach
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // Initialize audioEngine
    private let audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable button until speech isn't initialized
        buttonRecord.isEnabled = false
        
        // Put delegate on this View Controller
        speechRecognizer.delegate = self
        
        // Create a request authorization for Speech features
        SFSpeechRecognizer.requestAuthorization { (status :SFSpeechRecognizerAuthorizationStatus) in
            var isEnable = false
            
            switch status {
            case .authorized:
                isEnable = true
            case .denied:
                isEnable = false
                print("DENIED")
            case .notDetermined:
                isEnable = false
                print("NOT DETERMINED")
            case .restricted:
                isEnable = false
                print("RESTRICTED")
            }
            
            OperationQueue.main.addOperation() {
                self.buttonRecord.isEnabled = isEnable
            }
            
        }
        
//        let stringLegal = "VAMOS NO JAPONES HOJE"
//        print(stringLegal.score("Vamos no japones hoje"))
//        print(stringLegal.score("VAMOS NO JAPO HJ"))
//        print(stringLegal.score("JEFF VAMO NO JAPO HJ", fuzziness:0.5) )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func actionRecordAudio(_ sender: AnyObject) {
        // if audio engine is getting audios from mic
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            let strText = "Vamos no japonês hoje"
            let score = strText.score(self.textViewWords.text, fuzziness: 0.5)
            
            print("SCORE DOIDO - \(strText)")
            print("SCORE DOIDO - \(self.textViewWords.text)")
            print("SCORE DOIDO - \(score)")
            
            labelScore.text = NSString(format: "%.2f", score * 10.0) as String
            self.buttonRecord.isEnabled = false
            self.buttonRecord.setTitle("Gravar", for: .normal)
            
        } else {
            startRecording()
            self.buttonRecord.setTitle("Parar", for: .normal)

        }
        
    }
    
    
    func startRecording() {
        // if recognition thread is running cancel it
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Initialize audio session with parameters
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        // Init audiobuffer to speech recoginition
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
    
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        
        // Send text always that iOS recognize a word
        recognitionRequest.shouldReportPartialResults = true
        
        // Create a task for speech
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            // if has a word speeched then show in textview
            if result != nil {
                self.textViewWords.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            //
            if error != nil || isFinal {
                // if detect final of speech, turn off mic
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.buttonRecord.isEnabled = true
            }
        })
        
        // Configure recording format
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        self.textViewWords.text = "Fala que eu te escuto:"
        
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            buttonRecord.isEnabled = true
        } else {
            self.buttonRecord.isEnabled = false
        }
    }
    
}

