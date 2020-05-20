//
//  LoginViewController.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/19.
//  Copyright © 2020 com.sg. All rights reserved.
//

import UIKit
import Firebase


class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signIn: UIButton!
    let remoteconfig = RemoteConfig.remoteConfig()
    var color : String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // 버튼 및 텍스트 필드 라이브러리에서 가져오기
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (m) in
            m.right.top.left.equalTo(self.view)
            m.height.equalTo(20)
            
        }
       
        color = remoteconfig["splash_background"].stringValue
       // statusBar.backgroundColor = UIColor(hex: color)
        loginButton.backgroundColor = UIColor(hex: color)
        signIn.backgroundColor = UIColor(hex: color)
    }
    
    
    


 

}
