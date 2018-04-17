//
//  RecordViewController.swift
//  PitchPerfect
//
//  Created by Rafael Cunha de Oliveira on 03/04/18.
//  Copyright © 2018 Rafael Cunha de Oliveira. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    var isRecordButton = true
    var recordTimer = Timer()
    var timer = -1
    var recorLabelMessage = ""
    
    var audioRecorder: AVAudioRecorder!
    
    enum ButtonType: Int{
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recordLabel.text = "Ready to Record"
        recordTimer.invalidate()
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    
    //MARK: - layout
    
    func configureUI(isRecording: Bool){
        if(isRecording){
            recordLabel.text = "Recording"
            recordButton.setImage(UIImage(named: "Stop.png"), for: .normal)
            recordTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RecordViewController.updateRecordLabel), userInfo: nil, repeats: true)
        }else{
            recordButton.setImage(UIImage(named: "Record.png"), for: .normal)
        }
    
    }
    
    //MARK: - logic methods

    func startRecording(_ sender: Any) {
        self.configureUI(isRecording: true)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func stopRecording(_ sender: Any) {
        self.configureUI(isRecording: false)
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag{
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        }else{
            print("fail")
        }
    }
    
    @objc func updateRecordLabel(){
        self.timer += 1
        switch self.timer {
        case 0:
            self.recordLabel.text = "Recording."
            break
        case 1:
            self.recordLabel.text = "Recording.."
            break
        case 2:
            self.recordLabel.text = "Recording..."
            break
        default:
            self.recordLabel.text = "Recording"
            self.timer = -1
            break
        }
    }
    
    //MARK: - Actions
    
    @IBAction func buttonPressed(_ sender: Any) {
        if isRecordButton{
            self.startRecording(sender)
            self.isRecordButton = false
        }else{
            self.stopRecording(sender)
            self.isRecordButton = true
        }
    }
    
    //MARK: - segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording"{
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
}

