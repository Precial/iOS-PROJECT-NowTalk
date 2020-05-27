//
//  SignupViewController.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/20.
//  Copyright © 2020 com.sg. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignupViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordCheck: UITextField!
    @IBOutlet weak var name: UITextField!
    
  
    @IBOutlet weak var imageView: UIImageView!
    
    /* 이용 약관 체크 변수*/
    var agreeNextCode = 0
    
    /* 이용약관 체크버튼 */
       @IBOutlet weak var agreeCheckButton: UIButton!
       @IBOutlet weak var agreeCheckButton2:  UIButton!
    
   /* 이용 약관 체크 변수*/
    var agreeCodeName = ""
    
    
    /* 알람창 띄우는 메시지 변수 */
    var createMessage: String = ""
    var createTrue: Bool = false
    
    
    var imgdownloadURL = ""
    
    
    /* 이미지 컨트롤러 가져오기 */
      let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

         navigationController?.navigationBar.isHidden = true
        picker.delegate = self

    }
    
       override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true // 다시 초기화면으로 돌아 왔을때 네이게이션 바 제거
    }
    
    
    /* 회원가입 이벤트 */
    func signupEvent(){
         Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
           
            if user != nil {
            let uid = user?.user.uid
             self.createMessage = "회원가입이 완료되었습니다."
             self.createTrue = true // 회원가입을 진행해도 되는 비교 값
            
            
                                        guard let sendimage = self.imageView.image, let dataa = sendimage.jpegData(compressionQuality: 1.0) else {
                                                   return
                                               }
                                         
                                        /* 이미지를 저장할 path 설정 */
                                       
                                        let riversRef = Storage.storage().reference().child("userImages").child(uid!)
                                        
                                        
                                        /* 사용자가 선택한 이미지를 서버로 전송하는 부분 */
                                        riversRef.putData(dataa, metadata: nil) { (metadata, error) in
                                        guard let metadata = metadata else {
                                        // Uh-oh, an error occurred!
                                        return
                                        }
                                        
                                        // Metadata contains file metadata such as size, content-type.
                                        let size = metadata.size
                                        // You can also access to download URL after upload.
                                        riversRef.downloadURL { (url, error) in
                                        guard let downloadURL = url else {
                                           
                                        return
                                                  }
                                       
                                            self.imgdownloadURL = "\(downloadURL)"
                                            
                                        
                                            
                                            let sendUid = "\(uid!)"
                                            
                                            self.userAddDate(uid: sendUid, imgUrl: self.imgdownloadURL,userName: self.name.text!)
                                              }
                                         
                                          }
            
               
          //  Database.database().reference().child("users").child(uid!).setValue(["userName":self.name.text!])
            } else {
                /* 회원정보가 올바르지 않을 경우 알람창 호출 */
                self.createMessage = "이미있는 계정이거나 입력하신 정보가 올바르지 않습니다."
                self.createTrue = false
                self.createStopMessage(msg: self.createMessage)
            }
        }
        
    }
    
    /* 사용자 정보 DB에 저장 */
    func userAddDate(uid:String ,imgUrl: String, userName: String){
        let values = ["userName":userName,"profileImageUrl":imgUrl,"uid":Auth.auth().currentUser?.uid]
        Database.database().reference().child("users").child(uid).setValue(values, withCompletionBlock: { (err,ref) in
            
            if(err==nil) {
               self.createStopMessage(msg: self.createMessage)
                
            }
            
        })
        
        
        
        //dismiss(animated: true, completion: nil)
    }
    
    
    /* 약관 동의 버튼 클릭시 동작하는 부분 */
    @IBAction func agreeCheckBtn(_ sender: Any) {
        agreeCheckButton.isSelected = !agreeCheckButton.isSelected // 클릭할때 마다 상태 값 변화
    }
    @IBAction func agreeCheckBtn2(_ sender: Any) {
          agreeCheckButton2.isSelected = !agreeCheckButton2.isSelected // 클릭할때 마다 상태 값 변화
    }
    
    
    @IBAction func agreeContent1(_ sender: Any) {
        agreeCodeName = "DefaultAgree"
      
        agreePageNext()
 
    }
    @IBAction func agreeContent2(_ sender: Any) {
        agreeCodeName = "PersonalAgree"
             
        agreePageNext()
    }
    
    func agreePageNext(){
            //   print("log:[특검]")
         guard let rvc = self.storyboard?.instantiateViewController(withIdentifier:"showAgree") as? AgreeViewController else {
             return
         }
          rvc.receiveCodeName = self.agreeCodeName // 약관동의 페이지의 사용자가 누른 약관동의 코드를 전송
         self.navigationController?.pushViewController(rvc, animated: true) // 약관내용보기로 이동
     }
    
    
    func createUser() {
        if self.password.text! == self.passwordCheck.text!{  // 비밀번호랑 재확인 비밀번호가 일치하는지 확인
              if self.agreeCheckButton.isSelected && self.agreeCheckButton2.isSelected{ // 약관동의가 모두 되어 있는지 확인
                 signupEvent() // 비밀번호 일치 & 약관을 모두 동의 할 경우 회원가입 하는 함수 호출
              } else {
                  createStopMessage(msg: "약관을 모두 동의해주세요.") // 약관을 모두 동의하지 않은 경우 알람창 호출
              }
          } else{
              createStopMessage(msg: "비밀번호가 일치하지 않습니다.") // 비밀번호가 일치하지 않은 경우 알람창 호출
          }
      }
    
    
    
    /* 회원가입 클릭시 성공 or 실패를 알려주는 함수 */
    func createStopMessage(msg: String){
        let alert = UIAlertController(title: "", message: msg, preferredStyle: .alert)
                               alert.addAction(UIAlertAction(title: "확인", style: .default){
                               UIAlertAction in
                                  if self.createTrue {
                                    self.dismiss(animated: true, completion: nil)
                                }
                         })
                        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
           self.view.endEditing(true)
     }
    
    /* 회원가입 버튼 클릭 시 */
    @IBAction func createBtn(_ sender: Any) {
        createUser()
    }
    
    /* 가입취소 버튼 클릭 시 */
    @IBAction func cancleBtn(_ sender: Any) {
        cancleEvent()
    }
    
    func cancleEvent(){
        try! Auth.auth().signOut()
        dismiss(animated: true, completion: nil)
    }
    


    /* 이미지 불러오기 이벤트 */
    @IBAction func addImage(_ sender: Any) {
            let alert =  UIAlertController(title: "원하는 타이틀", message: "원하는 메세지", preferredStyle: .actionSheet)
                    let library =  UIAlertAction(title: "사진앨범", style: .default) { (action) in self.openLibrary()
                    }
                    let camera =  UIAlertAction(title: "카메라", style: .default) { (action) in
                        self.openCamera()
                    }
                    let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                    
                    alert.addAction(library)
                    alert.addAction(camera)
                    alert.addAction(cancel)
                    present(alert, animated: true, completion: nil)
        }
        
          func openLibrary()
          {
              picker.sourceType = .photoLibrary
              present(picker, animated: false, completion: nil)

          }
          func openCamera()
          {
              if(UIImagePickerController .isSourceTypeAvailable(.camera)){
                  picker.sourceType = .camera
                  present(picker, animated: false, completion: nil)
              }
              else{
                  print("Camera not available")
              }
          }
    
    
    
    
    

}
extension SignupViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {


        
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            print("log[이미지 값 확인]: \(image)")
        }
        
       
        

        dismiss(animated: true, completion: nil)

    }
}
