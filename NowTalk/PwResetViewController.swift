//
//  PwResetViewController.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/26.
//  Copyright © 2020 com.sg. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PwResetViewController: UIViewController {

    @IBOutlet weak var findID: UITextField! // 찾으실 이메일을 입력받는 필드
    
    /* 컨트롤러 뷰안에 뷰를 하나 더 생성하여 메인 뒤 뷰에 투명도를 부여하여 페이지 이동이 아닌 팝업창 느낌이 나도록 구현 */
    @IBOutlet weak var popupView: UIView!
    
    /* 앱이 로드 되었을 때 */
    override func viewDidLoad() {
        super.viewDidLoad()
        /* 나타나는 팝업뷰에 테두리를 둥근 테두리로 나타내기 */
        popupView.layer.cornerRadius = 30
    }
    
    /* 확인버튼을 클릭할 시 동작하는 부분 */
    @IBAction func sendPwReset(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: findID.text!) // 입력한 이메일로 비밀번호 재설정 보내기
        createUserMessage() // 완료 알람창 띄우는 함수 호출
    }
    
    /* 취소버튼을 클릭할 시 동작하는 부분 */
    @IBAction func cancleBtn(_ sender: Any) {
         dismiss(animated: true, completion: nil) // 이전 페이지로 이동
    }
    
    /* 전송 완료 알람창 띄우는 함수 */
    func createUserMessage(){
           let alert = UIAlertController(title: "", message: "요청하신 이메일로 발송하였습니다.", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "확인", style: .default){
               UIAlertAction in
                self.dismiss(animated: true, completion: nil)
         })
        present(alert, animated: true, completion: nil)
       }
}
