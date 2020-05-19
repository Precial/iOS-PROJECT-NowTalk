//
//  ViewController.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/19.
//  Copyright © 2020 com.sg. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class ViewController: UIViewController {
    
    var box = UIImageView()
    var remoteConfig : RemoteConfig!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
           remoteConfig - 서버에서 값을 받아와 앱을 처리하는 방식으로 공지사항 및 업데이트 할 때 앱의 접근을 제어 할 수 있음.
         */
        
        
        // remoteConfig 연결 및 세팅
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        
        
        // remoteConfig 서버 값 받기
        remoteConfig.fetch(withExpirationDuration: TimeInterval(0)) { (status, error) -> Void in
          if status == .success {
            print("Config fetched!")
            self.remoteConfig.activate() { (error) in
              // ...
            }
          } else {
            print("Config not fetched")
            print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
          self.displayWelcome()
        }
        
    
        self.view.addSubview(box)
        box.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
        }
        box.image = #imageLiteral(resourceName: "loading_icon")
        // self.view.backgroundColor = UIColor(hex: "#000000") // 배경색 변경
    }
    
    
    /* 서버에서 값 가져와서 처리하는 구간 */
    func displayWelcome() {
        
        let color = remoteConfig["splash_background"].stringValue
        let caps =  remoteConfig["splash_message_caps"].boolValue
        let message =  remoteConfig["splash_message"].stringValue
        
        print("log: cpas 값은 = \(caps) ")
        
        if(caps) {
            let alert = UIAlertController(title: "공지사항", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { (action) in
                exit(0)
        }))
        
            self.present(alert, animated: true, completion: nil)
            
    }
        self.view.backgroundColor = UIColor(hex: color!)


}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
