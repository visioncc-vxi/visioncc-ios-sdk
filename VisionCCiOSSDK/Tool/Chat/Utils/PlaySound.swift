//
//  PlaySound.swift
//  HTFinanceRed
//
//  Created by fx678.com on 2018/1/11.
//  Copyright © 2018年 com.fx678.appfinace. All rights reserved.
//

import UIKit
import AVFAudio
import AudioToolbox
import CoreFoundation


class PlaySound: NSObject {
    
    private lazy var player:AVAudioPlayer? = nil
    
    /// 振动
    func systemVibration(){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    /// 播放提示音
    /// - Parameters:
    ///   - strVoiceName: <#strVoiceName description#>
    ///   - strType: <#strType description#>
    func playVoice(strVoiceName:String,
                   strType:String = "mp3"){
        guard let _path = Bundle.main.path(forResource: strVoiceName, ofType: strType) else {
            print("文件不存在")
            return
        }
        
        do{
            let _fileUrl = URL.init(fileURLWithPath: _path,isDirectory: false)
            var soundId:SystemSoundID = 1
            AudioServicesCreateSystemSoundID(_fileUrl as CFURL, &soundId)
            
            //播放声音
            AudioServicesPlaySystemSound(soundId)
        }
    }
    
    
    /// 播放背景乐
    /// - Parameters:
    ///   - strMName: String 文件名
    ///   - strType: String 后缀名
    func playMusic(strMName:String,
                   strType:String = "mp3"){
        
        guard let _path = Bundle.main.path(forResource: strMName, ofType: strType) else {
            print("文件不存在")
            return
        }
        
        do{
            let _url = URL.init(fileURLWithPath: _path)
            player = try? AVAudioPlayer(contentsOf: _url)
            
            player?.prepareToPlay()
            player?.numberOfLoops = -1//设置音乐播放次数  -1为一直循环
            
            player?.volume = 1.0
            player?.play()
        }
    }
    
    
    /// 销毁
    private func unInit(){
        self.player?.stop()
        self.player = nil
    }
    
    deinit {
        self.unInit()
        print("PlaySound 已销毁")
    }
}
