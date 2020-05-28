//
//  AccountViewController.swift
//  NowTalk
//
//  Created by 장성구 on 2020/05/22.
//  Copyright © 2020 com.sg. All rights reserved.
//

import UIKit
import Firebase


class AccountViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
 
    

    
    @IBOutlet weak var conditionsCommentButton: UIButton!
    
    
    let viewModel = BountyViewModel()
    
    
    //performSegue 가 실행되기전 준비하는 과정
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // DetailViewController 데이터 wnrl
        
        if segue.identifier == "showDetail" {
            let vc = segue.destination as? DetailViewController
            if let index = sender as? Int{

                let bountyInfo = viewModel.bountyInfo(at: index)

                vc?.viewModel.update(model: bountyInfo)
           }
        
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
           let lbNavTitle = UILabel (frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        
           lbNavTitle.textColor = UIColor.black
           lbNavTitle.textAlignment = .left
           lbNavTitle.font = .systemFont(ofSize: 22, weight: .semibold)
           lbNavTitle.text = "  더보기"


           self.navigationItem.titleView = lbNavTitle

        
        conditionsCommentButton.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
        
    }
    

    @objc func showAlert() {
        
        let alertController = UIAlertController(title: "상태 메시지", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { (textfiled) in
            textfiled.placeholder = "상태메시지를 입력해주세요"
        }
        
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler:{ (action) in
            
            if let textfiled = alertController.textFields?.first {
                
                let dic = ["comment" : textfiled.text!]
                let uid = Auth.auth().currentUser?.uid
                Database.database().reference().child("users").child(uid!).updateChildValues(dic)
                
            }
                
                
            
            
        }))
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action)
                in
            }))
            
            self.present(alertController, animated: true, completion: nil)
    }
    
    
     // 몇개를 보여줄까요
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numOfBountyInfoList
    }
    
    // 셀은 어떻게 표현할꺼야?
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as? GridCell else {
            return UICollectionViewCell()
        }
            
            
            let bountyInfo = viewModel.bountyInfo(at: indexPath.item)
            cell.update(info: bountyInfo)
            cell.update(info: bountyInfo)
            return cell
    }
    
    // UICollectionViewDelegate,
    // 셀이 클릭되었을떄 어쩔까요
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("--> \(indexPath.item)")
        performSegue(withIdentifier: "showDetail", sender: indexPath.item)
    }
    

  //   UICollectionViewDelegateFlowLayout
    // cell size를 계산할거다 ( 목표: 다양한 디바이스에서 일관적인 디자인을 보여주기 위해)
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    

        let width: CGFloat = 70
        let height: CGFloat = 70

        return CGSize(width: width, height: height)
    }
    
    

}

class BountyViewModel {
    let bountyInfoList: [BountyInfo] = [
        BountyInfo(name: "선물하기"),
            BountyInfo(name: "이모티콘"),
            BountyInfo(name: "주문하기"),
            BountyInfo(name: "스타일"),
            BountyInfo(name: "쇼핑하기"),
            BountyInfo(name: "페이지"),
            BountyInfo(name: "게임"),
            BountyInfo(name: "음악")
       ]
    

    
    var numOfBountyInfoList: Int {
        return bountyInfoList.count
    }
    
    func bountyInfo(at index: Int) -> BountyInfo {
        return bountyInfoList[index]
    }
}

class GridCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bountyLabel: UILabel!
    
    func update(info: BountyInfo) {
            imgView.image =  info.image
            nameLabel.text = info.name
            
    }
    
}
