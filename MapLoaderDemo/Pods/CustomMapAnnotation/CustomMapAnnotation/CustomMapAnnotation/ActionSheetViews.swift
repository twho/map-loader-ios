//
//  ActionSheetViews.swift
//  LocationAudioMessage
//
//  Created by Ho, Tsung Wei on 7/19/18.
//  Copyright © 2018 Michael Ho. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - AudioView
open class AudioView: UIView {
    
    let LOG_TAG = "[CustomMapAnnotation AudioView] "
    
    /**
     The subtitle of the callout audio view.
     */
    @IBOutlet weak var labelSubTitle: UILabel!
    
    /**
     The title of the callout audio action sheet.
     */
    @IBOutlet weak var labelTitle: UILabel!
    
    /**
     The play button of the audio action sheet.
     */
    @IBOutlet weak var btnPlay: ActionSheetButton!
    
    /**
     The stop button of the audio action sheet.
     */
    @IBOutlet weak var btnStop: ActionSheetButton!
    
    /**
     The record button of the audio action sheet.
     */
    @IBOutlet weak var btnRecord: ActionSheetButton!
    
    /**
     The set of the buttons in audio action sheet.
     */
    private var buttons: [ActionSheetButton]!
    
    // MARK: - Audio Utils
    /**
     The audio player used in audio action sheet view.
     */
    var audioPlayer: AVAudioPlayer?
    
    /**
     Type alias of input external function or logic
     */
    public typealias audioViewFunction = ((AudioView) -> ())
    
    /**
     Used to stored function for record button click event.
     */
    private var onClickRecord: ((AudioView) -> Void)? = nil
    
    /**
     Used to stored function for fetching audio data.
     */
    private var fetchAudio: audioViewFunction? = nil
    private var audioData: Any? = nil
    
    /**
     Set true to hide top bar.
     */
    public var isTopBarHidden: Bool = false {
        didSet {
            labelTitle.isHidden = isTopBarHidden
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        // Add button click event
        btnPlay.addTarget(self, action: #selector(onClickBtnPlay), for: .touchUpInside)
        btnStop.addTarget(self, action: #selector(onClickBtnStop), for: .touchUpInside)
        btnRecord.addTarget(self, action: #selector(onClickBtnRecord), for: .touchUpInside)
        
        buttons = [btnPlay, btnStop, btnRecord]
        
        // Set image resource
        btnPlay.setImageForAllState(image: CMAResManager.ActionSheetBtnImg.play.image)
        btnStop.setImageForAllState(image: CMAResManager.ActionSheetBtnImg.stop.image)
        btnRecord.setImageForAllState(image: CMAResManager.ActionSheetBtnImg.record.image)
    }
    
    /**
     Instantiate audio view
     
     - Parameter vcOwner: The owner of the audio view.
     */
    public static func instantiate(_ vcOwner: UIViewController) -> AudioView? {
        let audioView = UINib(nibName: "CMAAudioView", bundle: CMAResManager.getBundle(bundleType: .viewNibs)).instantiate(withOwner: vcOwner, options: nil)[0] as? AudioView
        
        return audioView
    }
    
    /**
     Configure audio action sheet with input paramters.
     
     - Parameters:
        - title:         The title of the audio action sheet.
        - subTitle:      The subtitle of the audio action sheet.
        - theme:         The theme of the action sheet.
        - fetchAudio:    Customized method for fetching audio data.
        - onClickRecord: Customized button click event.
     */
    public func configure(title: String? = nil, subTitle: String? = nil, theme: CMAResManager.Theme = .dark, fetchAudio: @escaping audioViewFunction, onClickRecord: audioViewFunction? = nil) {
        self.fetchAudio = fetchAudio
        configure(title: title, subTitle: subTitle, theme: theme, audioData: fetchAudio, onClickRecord: onClickRecord)
    }
    
    /**
     Configure audio action sheet with input paramters.
     
     - Parameters:
        - title:         The title of the audio action sheet.
        - subTitle:      The subtitle of the audio action sheet.
        - theme:         The theme of the action sheet.
        - audioData:     The audio data to be used in audio action sheet.
        - onClickRecord: Customized button click event.
     */
    public func configure(title: String? = nil, subTitle: String? = nil, theme: CMAResManager.Theme = .dark, audioData: Any, onClickRecord: audioViewFunction? = nil) {
        self.audioData = audioData
        self.labelTitle.text = title
        self.labelSubTitle.text = subTitle
        
        if let onClickRecord = onClickRecord {
            self.onClickRecord = onClickRecord
        }
        
        btnRecord.isEnabled = onClickRecord != nil
        
        setTheme(theme: theme)
    }
    
    /**
     Handle play button click event.
     */
    @objc func onClickBtnPlay() {
        if nil != audioPlayer && (audioPlayer?.isPlaying)! {
            btnPlay.setImageForAllState(image: CMAResManager.ActionSheetBtnImg.play.image)
            audioPlayer?.pause()
        } else {
            btnPlay.isLoading = true
            guard let audioData = audioData else { return }
            if nil != self.fetchAudio {
                self.fetchAudio!(self)
            } else {
                playAudio(resource: audioData)
            }
        }
    }
    
    /**
     Play audio with specified resource.
     
     - Parameter resource: The audio data resource either in URL or Data form.
     */
    public func playAudio(resource: Any) {
        // Setup GUIs before playing audio
        btnRecord.isEnabled = false
        btnPlay.setImageForAllState(image: CMAResManager.ActionSheetBtnImg.pause.image)
        btnPlay.isLoading = false
        
        do {
            if let data = (resource as? Data) {
                audioPlayer = try AVAudioPlayer(data: data)
            } else if let url = (resource as? URL) {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            }
            
            guard let audioPlayer = audioPlayer else { return }
            
            audioPlayer.prepareToPlay()
            audioPlayer.delegate = self
            audioPlayer.play()
        } catch let error as NSError {
            print(LOG_TAG + "\(error.description)")
        }
    }
    
    /**
     Handle stop button click event.
     */
    @objc func onClickBtnStop() {
        if nil != audioPlayer && (audioPlayer?.isPlaying)! {
            audioPlayer?.stop()
            audioPlayer = nil
        }
        
        btnPlay.setImageForAllState(image: CMAResManager.ActionSheetBtnImg.play.image)
    }
    
    /**
     Handle record button click event.
     */
    @objc func onClickBtnRecord() {
        if let onClickRecord = onClickRecord {
            onClickRecord(self)
        }
    }
    
    /**
     Set custom button image
     
     - Parameters:
        - leftBtnImg:  The image to be set to the left button.
        - midBtnImg:   The image to be set to the middle button.
        - rightBtnImg: The image to be set to the right button.
     */
    public func setButtonImage(leftBtnImg: UIImage? = nil, midBtnImg: UIImage? = nil, rightBtnImg: UIImage? = nil) {
        
        if let image = leftBtnImg {
            btnPlay.setImage(image, for: UIControlState())
        }
        
        if let image = midBtnImg {
            btnStop.setImage(image, for: UIControlState())
        }
        
        if let image = rightBtnImg {
            btnRecord.setImage(image, for: UIControlState())
        }
        
        self.setNeedsDisplay()
    }
    
    /**
     Setup different theme view colors.
     
     - Parameters:
        - theme:       The Theme of the action sheet.
        - bgColor:     The background color of the action sheet.
        - textColor:   The text color of the entire action sheet.
        - topBarColor: The background color of the top bar.
     */
    public func setTheme(theme: CMAResManager.Theme, bgColor: UIColor? = nil, textColor: UIColor? = nil, topBarColor: UIColor? = nil) {
        let themeColors = CMAResManager.getColorByTheme(theme: theme, bgColor: bgColor, textColor: textColor, topBarColor: topBarColor)
        
        labelTitle.textColor = themeColors.textColor
        labelSubTitle.textColor = themeColors.textColor
        self.backgroundColor = themeColors.bgColor.color
        self.labelTitle.backgroundColor = themeColors.TopBarColor
        
        for button in buttons {
            button.setButtonStyle(normal: themeColors.bgColor.color, clicked: themeColors.bgColor.tint, disabled: CMAResManager.Color.ltGray)
        }
        
        self.setNeedsDisplay()
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioView: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer = nil // Clean up
        btnPlay.setImageForAllState(image: CMAResManager.ActionSheetBtnImg.play.image)
        btnRecord.isEnabled = onClickRecord != nil
    }
}

// MARK: - InfoView
open class InfoView: UIView {
    
    /**
     Like button to let user rate the information.
     */
    @IBOutlet weak var btnLike: ActionSheetButton!
    
    /**
     Used to diaply information content image.
     */
    @IBOutlet weak var btnInfo: ActionSheetButton!
    
    /**
     The title of the callout audio action sheet.
     */
    @IBOutlet weak var labelTitle: UILabel!
    
    /**
     The subtitle of the callout audio action sheet.
     */
    @IBOutlet weak var labelSubTitle: UILabel!
    
    /**
     The content of the callout audio action sheet.
     */
    @IBOutlet weak var labelContent: UILabel!
    
    /**
     A tuple of like button image. Configurable from external.
     */
    public var btnLikeImage = (isLiked: CMAResManager.ActionSheetBtnImg.like.image, notLiked: CMAResManager.ActionSheetBtnImg.dislike.image)
    
    /**
     Type alias of input external function or logic
     */
    public typealias infoViewFunction = ((InfoView) -> ())
    
    /**
     Used to stored function for like button click event.
     */
    private var onClickLike: ((InfoView) -> Void)? = nil
    
    /**
     Flag indicated if the like button is clicked.
     */
    private var isLiked = false
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        btnLike.addTarget(self, action: #selector(onClickBtnLike), for: .touchUpInside)
    }
    
    /**
     Instantiate audio view
     
     - Parameter vcOwner: The owner of the audio view.
     */
    public static func instantiate(_ vcOwner: UIViewController) -> InfoView? {
        let infoView = UINib(nibName: "CMAInfoView", bundle: CMAResManager.getBundle(bundleType: .viewNibs)).instantiate(withOwner: vcOwner, options: nil)[0] as? InfoView
        
        return infoView
    }
    
    /**
     Configure audio action sheet with input paramters.
     
     - Parameters:
        - title:       The title of the info action sheet.
        - content:     The content of the info action sheet.
        - subTitle:    The subtitle of the info action sheet.
        - image:       The image of the info action sheet.
        - liked:       Indicatd if the information is liked.
        - theme:       The theme of the action sheet.
        - onClickLike: Customized button click event.
     */
    public func configure(title: String? = nil, content: String, subTitle: String? = nil, image: UIImage, liked: Bool, theme: CMAResManager.Theme = .dark, onClickLike: @escaping infoViewFunction) {
        self.labelTitle.text = title
        self.labelContent.text = content
        self.labelSubTitle.text = subTitle
        self.onClickLike = onClickLike
        self.btnInfo.setImageForAllState(image: image)
        self.isLiked = liked
        alternateBtnLikeState()
        
        setTheme(theme: theme)
    }
    
    /**
     Handle like button click event.
     */
    @objc func onClickBtnLike() {
        isLiked = !isLiked
        alternateBtnLikeState()
        
        if let onClickLike = onClickLike {
            onClickLike(self)
        }
    }
    
    /**
     Alternate like button state
     */
    public func alternateBtnLikeState() {
        btnLike.setImageForAllState(image: isLiked ? btnLikeImage.isLiked : btnLikeImage.notLiked)
    }
    
    /**
     Set like button image for two different states
     
     - Parameters:
        - isLikedImg: The image for like state.
        - isLikedImg: The image for dislike state.
     */
    public func setBtnLikeImage(isLikedImg: UIImage, notLikedImg: UIImage) {
        btnLikeImage = (isLiked: isLikedImg, notLiked: notLikedImg)
    }
    
    /**
     Setup different theme view colors.
     
     - Parameters:
         - theme:       The Theme of the action sheet.
         - bgColor:     The background color of the action sheet.
         - textColor:   The text color of the entire action sheet.
         - topBarColor: The background color of the top bar.
     */
    public func setTheme(theme: CMAResManager.Theme, bgColor: UIColor? = nil, textColor: UIColor? = nil, topBarColor: UIColor? = nil) {
        let themeColors = CMAResManager.getColorByTheme(theme: theme, bgColor: bgColor, textColor: textColor, topBarColor: topBarColor)
        
        labelTitle.textColor = themeColors.textColor
        labelContent.textColor = themeColors.textColor
        labelSubTitle.textColor = themeColors.textColor
        self.backgroundColor = themeColors.bgColor.color
        self.labelTitle.backgroundColor = themeColors.TopBarColor
        btnLike.titleLabel?.textColor = themeColors.textColor
        btnLike.setButtonStyle(normal: themeColors.bgColor.color, clicked: themeColors.bgColor.tint, disabled: CMAResManager.Color.ltGray)
        btnInfo.setButtonStyle(normal: themeColors.bgColor.color, clicked: themeColors.bgColor.tint, disabled: CMAResManager.Color.ltGray)
        
        self.setNeedsDisplay()
    }
}
