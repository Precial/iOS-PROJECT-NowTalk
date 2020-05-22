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
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // try! Auth.auth().signOut()
        
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
        

       /* Auth.auth().addStateDidChangeListener는 로그인 상태가 변할때 동작하는 부분 */
               Auth.auth().addStateDidChangeListener { (auth, user) in
                         if let user = user {
                           self.performSegue(withIdentifier: "loginNext", sender: self) // 현재 사용자가 로그인 된 상태가 맞다면 다음 화면으로 이동
                           }
                   }
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {

         super.didReceiveMemoryWarning()

                 try! Auth.auth().signOut()

     }
    
    /* 키보드창 내리기 */
      override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
            self.view.endEditing(true)
      }
    
    
    func loginEvent(){
       /* 테스트 모드 */
            // self.performSegue(withIdentifier: "loginNext", sender: self)
            
            /* 상용모드 */
            Auth.auth().signIn(withEmail: email.text!, password: password.text!){ // 입력한 ID,PW로 로그인 인증하는 부분
                (user, error) in if user != nil {
                    print("로그인 성공")
                    // 로그인시 ID,PW 입력창 초기화
                    self.email.text!=""
                    self.password.text!=""
                } else {
                    print("로그인 불가")
                    self.loginFailMessage() // 로그인 실패시 에러 알림창 출력 함수 호출
                }
            }
    }

    /* 로그인 버튼 클릭 시 */
    @IBAction func loginBtn(_ sender: Any) {
        loginEvent()
    }
    
    /* 로그인 실패시 알람창 띄우는 함수 */
       func loginFailMessage() {
            let message = "아이디/ 비밀번호가 맞지 않습니다."
            let alert = UIAlertController(title: "로그인 실패", message: message, preferredStyle:.alert)
            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(action)
            present(alert,animated: true, completion: nil)
        }
    
    
 

}
