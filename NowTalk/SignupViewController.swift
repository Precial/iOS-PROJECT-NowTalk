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
    @IBOutlet weak var name: UITextField!
    
  
    @IBOutlet weak var imageView: UIImageView!
    
    /* 이용 약관 체크 변수*/
    var agreeNextCode = 0
    
    /* 이용약관 체크버튼 */
       @IBOutlet weak var agreeCheckButton: UIButton!
       @IBOutlet weak var agreeCheckButton2:  UIButton!
    
    
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
            let uid = user?.user.uid
            
          
            
            // Firebase Storage 이미지 저장
    
            /* 전송할 이미지를 데이터로 변환 */
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
                                          print("log: \(downloadURL)")
                                            self.imgdownloadURL = "\(downloadURL)"
                                            
                                            print("log [1] = \(self.imgdownloadURL)")
                                            print("log [2] = \(uid!)")
                                            
                                            let sendUid = "\(uid!)"
                                            
                                            self.userAddDate(uid: sendUid, imgUrl: self.imgdownloadURL,userName: self.name.text!)
                                              }
                                         
                                          }
            
               
          //  Database.database().reference().child("users").child(uid!).setValue(["userName":self.name.text!])
            
        }
        
    }
    
    /* 사용자 정보 DB에 저장 */
    func userAddDate(uid:String ,imgUrl: String, userName: String){
        let values = ["userName":userName,"profileImageUrl":imgUrl,"uid":Auth.auth().currentUser?.uid]
        Database.database().reference().child("users").child(uid).setValue(values, withCompletionBlock: { (err,ref) in
            
            if(err==nil) {
                self.cancleEvent()
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
        agreeNextCode=0
      
        agreePageNext()
 
    }
    @IBAction func agreeContent2(_ sender: Any) {
        agreeNextCode=1
             
        agreePageNext()
    }
    
    func agreePageNext(){
               print("log:[특검]")
         guard let rvc = self.storyboard?.instantiateViewController(withIdentifier:"showAgree") as? AgreeViewController else {
             return
         }
        // rvc.receiveCode = self.agreeNextCode // 약관동의 페이지의 사용자가 누른 약관동의 코드를 전송
         self.navigationController?.pushViewController(rvc, animated: true) // 약관내용보기로 이동
     }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
           self.view.endEditing(true)
     }
    
    /* 회원가입 버튼 클릭 시 */
    @IBAction func createBtn(_ sender: Any) {
        signupEvent()
    }
    
    /* 가입취소 버튼 클릭 시 */
    @IBAction func cancleBtn(_ sender: Any) {
        cancleEvent()
    }
    
    func cancleEvent(){
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
