//
//  TrackListViewController.swift
//  musicPlayerRevamped
//
//  Created by Sean Calkins on 9/29/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit
import AVFoundation

class TrackListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {

    var audioPlayer = AVAudioPlayer()
    var songs = [Song]()
    var currentSong = Song()
    var numberFormatter = NumberFormatter()
    var timer = Timer()
    
    
    @IBOutlet var customSlider: CustomUISlider!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var albumArtworkImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customSlider.value = 0
        
        numberFormatter.minimumIntegerDigits = 2
        
        let tracks = ["Evil Has No Boundaries", "The Antichrist", "Die By The Sword", "Fight Till Death", "Metal Storm  Face The Slayer", "Black Magic", "Tormentor", "The Final Command", "Crionics", "Show No Mercy"]
        
        for i in 1...tracks.count {
            
            let song = Song()
            song.title = tracks[i - 1]
            song.trackNumber = i
            self.songs.append(song)
            
        }
        
        timer = Timer(timeInterval: 1, target: self, selector: #selector(self.handleTimer), userInfo: nil, repeats: true)
        
        self.currentSong = self.songs.first!
        
        self.setupAudioPlayerWithCurrentSong()
       
        self.setUpUI()
        
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        
        if self.currentSong.title != "" {
            
            sender.isSelected = !sender.isSelected
            
            if sender.isSelected {
                // play
                self.currentSong.isPlaying = true
                self.audioPlayer.play()
                self.startTimer()
            
            } else {
                // pause
                self.audioPlayer.pause()
                self.timer.invalidate()
        
            }
            
            self.tableView.reloadData()
            
        }
        
    }
    
    @IBAction func rewindButtonTapped(_ sender: UIButton) {
        
        if self.audioPlayer.currentTime > 5 {
            
            self.setupAudioPlayerWithCurrentSong()
            self.audioPlayer.play()
            
        } else {
            
            self.playPreviousSong()
            
        }
        
    }
    
    @IBAction func fastForwardTapped(_ sender: UIButton) {
        
        self.playNextSong()
        
    }
   
    @IBAction func sliderValueChanged(_ sender: CustomUISlider) {
        
        self.audioPlayer.currentTime = (self.audioPlayer.duration * Double(sender.value))
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.currentSong = self.songs[indexPath.row]
        
        self.timer.invalidate()
        
        for song in self.songs {
            
            song.isPlaying = false
            
        }
        
        self.setupAudioPlayerWithCurrentSong()
        
        self.audioPlayer.play()
        
        self.startTimer()
        
        self.playPauseButton.isSelected = true
        
        self.setUpNowPlaying()
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return songs.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SongTableViewCell
       
        let song = songs[indexPath.row]
        
        cell.backgroundColor = .clear
        
        if song.isPlaying {
            
            cell.nowPlayingIcon.isHidden = false
            cell.trackNumberLabel.textColor = UIColor(red:0.29, green:0.85, blue:1.00, alpha:1.00)
            cell.songTitleLabel.textColor = UIColor(red:0.29, green:0.85, blue:1.00, alpha:1.00)
            
        } else {
            
            cell.nowPlayingIcon.isHidden = true
            cell.trackNumberLabel.textColor = .white
            cell.songTitleLabel.textColor = .white
            
        }
        
        if let number = numberFormatter.string(from: NSNumber(value: song.trackNumber)) {
            
            cell.trackNumberLabel.text = "\(number) -"
            
        }
      
        cell.songTitleLabel.text = song.title
        
        return cell
        
    }
    
    
    func applyBlurEffect(image: UIImage){
        let imageToBlur = CIImage(image: image)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter?.setValue(imageToBlur, forKey: "inputImage")
        let resultImage = blurfilter?.value(forKey: "outputImage") as! CIImage
        let blurredImage = UIImage(ciImage: resultImage)
        self.albumArtworkImageView.image = blurredImage
        
    }
    
    func setUpUI() {
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = .black
        }
        
        self.customSlider.minimumTrackTintColor = UIColor(red:0.29, green:0.85, blue:1.00, alpha:1.00)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.29, green:0.85, blue:1.00, alpha:1.00)
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        self.playNextSong()
        
    }
    
    func handleTimer() {
        
        self.updateSliderValue()
        
    }
    
    func updateSliderValue() {
        
        let value = Float(audioPlayer.currentTime) / Float(audioPlayer.duration)
            
        self.customSlider.value = value
        
    }
    
    func setupAudioPlayerWithCurrentSong() {
        
        if let number = numberFormatter.string(from: NSNumber(value: self.currentSong.trackNumber)) {
            
            if let path = Bundle.main.path(forResource: "\(number). \(self.currentSong.title)", ofType:".mp3") {
                
                let url = URL(fileURLWithPath: path)
                
                do {
                    
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    
                    self.audioPlayer.delegate = self
                    
                } catch {
                    
                    // couldn't load file :(
                    
                }
                
            } else {
                print("invalid url path")
                print("\(number). \(self.currentSong.title).mp3")
            }
            
        }
        
    }
    
    func startTimer() {
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.handleTimer), userInfo: nil, repeats: true)
        
    }
    
    func playNextSong() {
        
        if let indexOfCurrentSong = self.songs.index(where: { $0 === self.currentSong} ) {
            
            let newIndex = indexOfCurrentSong + 1
            
            if newIndex > self.songs.count - 1 {
                
                self.currentSong = songs[0]
                self.setupAudioPlayerWithCurrentSong()
                self.timer.invalidate()
                
            } else {
                
                self.currentSong = songs[newIndex]
                self.setupAudioPlayerWithCurrentSong()
                self.audioPlayer.play()
                
            }
            
        }
        
        self.setUpNowPlaying()
        
    }
    
    func playPreviousSong() {
        
        if let indexOfCurrentSong = self.songs.index(where: { $0 === self.currentSong} ) {
            
            let newIndex = indexOfCurrentSong - 1
          
            if newIndex < 0 {
                
                self.currentSong = songs[0]
                self.setupAudioPlayerWithCurrentSong()
                self.audioPlayer.play()
                
            } else {
                
                self.currentSong = songs[newIndex]
                self.setupAudioPlayerWithCurrentSong()
                self.audioPlayer.play()
                
            }
            
        }
        
        self.setUpNowPlaying()
        
    }
    
    func setUpNowPlaying() {
        
        for song in self.songs {
            
            song.isPlaying = false
            
        }
        
        self.currentSong.isPlaying = true
        
        self.tableView.reloadData()
        
    }
    
    
}


class CustomUISlider: UISlider
{
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        //keeps original origin and width, changes height, you get the idea
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 9.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
    
    
    //while we are here, why not change the image here as well? (bonus material)
    override func awakeFromNib() {
        self.setThumbImage(UIImage(named: "scrubber"), for: .normal)
        super.awakeFromNib()
    }
}


