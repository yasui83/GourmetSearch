//
//  ShopDetailViewController.swift
//  GourmetSearch
//
//  Created by 安井春輝 on 2017/10/04.
//  Copyright © 2017 haruki yasui. All rights reserved.
//

import UIKit
import MapKit

class ShopDetailViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tel: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    
    @IBOutlet weak var nameHeight: NSLayoutConstraint!
    @IBOutlet weak var addressContainerHeight: NSLayoutConstraint!
    
    var shop = Shop()
    
    let ipc = UIImagePickerController()
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //写真
        if let url = shop.photoUrl {
            photo.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "loading"));
        }else {
            photo.image = UIImage(named: "loading")
        }
        //店舗名
        name.text = shop.name
        //電話番号
        tel.text = shop.tel
        //住所
        address.text = shop.address
        //お気に入り状態をボタンラベルに反映
        updateFavoriteButton()
        
        //地図
        if let lat = shop.lat {
            if let lon = shop.lon {
                //地図の表示範囲を指定
                let cllc = CLLocationCoordinate2DMake(lat, lon)
                let mkcr = MKCoordinateRegionMakeWithDistance(cllc, 200, 200)
                map.setRegion(mkcr, animated: false)
                //ピンを設定
                let pin = MKPointAnnotation()
                pin.coordinate = cllc
                map.addAnnotation(pin)
                
                //お気に入り状態をボタンラベルに反映
                updateFavoriteButton()
            }
        }
        
        //UIImagePickerControllerDelegateの設定
        //Delegate設定
        ipc.delegate = self
        //トリミングなどを行う
        ipc.allowsEditing = true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.scrollView.delegate = self
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.scrollView.delegate = nil
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        let nameFrame = name.sizeThatFits(
            CGSize(width: name.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        nameHeight.constant = nameFrame.height
        
        let addressFrame = address.sizeThatFits(
            CGSize(width: address.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        addressContainerHeight.constant = addressFrame.height
        view.layoutIfNeeded()
    }
    
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        if scrollOffset <= 0 {
            photo.frame.origin.y = scrollOffset
            photo.frame.size.height = 200 - scrollOffset
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        ipc.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        ipc.dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - アプリケーションロジック
    func updateFavoriteButton(){
        guard let gid = shop.gid else {
            return
        }
        
        if Favorite.inFavorites(gid) {
            //お気に入りに入っている
            favoriteIcon.image = UIImage(named: "star-on")
            favoriteLabel.text = "お気に入りから外す"
        }else {
            //お気に入りに入っていない
            favoriteIcon.image = UIImage(named: "star-off")
            favoriteLabel.text = "お気に入りに入れる"
        }
        
    }
    
    
    
    //MARK: - IBAction
    @IBAction func telTapped(_ sender: UIButton) {
        print("telTapped")
    }
    
    @IBAction func addressTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "PushMapDetail", sender: nil)
    }
    
    @IBAction func favoriteTapped(_ sender: UIButton) {
        guard let gid = shop.gid else {
            return
        }
        
        //お気に入りセル：お気に入り状態を更新する
        Favorite.toggle(gid)
        updateFavoriteButton()
    }
    
    
    @IBAction func addPhotoTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //カメラが使えるか確認して使えるなら「写真を撮る」選択肢を表示
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(
                UIAlertAction(title: "写真を撮る", style: .default, handler: {
                    action in
                    //ソースはカメラ
                    self.ipc.sourceType = .camera
                    //カメラUIを起動
                    self.present(self.ipc, animated: true, completion: nil)
                })
            )
        }
        
        //「写真を選択」ボタンはいつでも使える
        alert.addAction(
            UIAlertAction(title: "写真を選択", style: .default, handler: {
                action in
                //ソースは写真選択
                self.ipc.sourceType = .photoLibrary
                //写真選択UIを起動
                self.present(self.ipc, animated: true, completion: nil)
            })
        )
        alert.addAction(
            UIAlertAction(title: "キャンセル", style: .cancel, handler: {
                action in
            })
        )
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    

    
     //MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushMapDetail" {
            let vc = segue.destination as! ShopMapDetailViewController
            vc.shop = shop
        }
    }
    
    
    
    
    
 

}
