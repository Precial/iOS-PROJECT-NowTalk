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
    
    
    var imgdownloadURL = ""
    
    
    /* 이미지 컨트롤러 가져오기 */
      let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        picker.delegate = self

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
                                             self.imgdownloadURL = "\(downloadURL)"
                                     
                                              }
                                         
                                           
                                          
                                                      
                                            
                                          }
              print("log[다운로드 경로]: \(self.imgdownloadURL)")
            Database.database().reference().child("users").child(uid!).setValue(["name":self.name.text!])
            
        }
        
    }
    
    /* 회원가입 버튼 클릭 시 */
    @IBAction func createBtn(_ sender: Any) {
        signupEvent()
    }
    
    /* 가입취소 버튼 클릭 시 */
    @IBAction func cancleBtn(_ sender: Any) {
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
