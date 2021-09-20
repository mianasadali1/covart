//
//  FirstVC.swift
//  FMPhotoPickerExample
//
//  Created by Apple on 08/09/21.
//  Copyright © 2021 Tribal Media House. All rights reserved.
//

import UIKit

class FirstVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var imgSelected: UIImageView!
    @IBOutlet weak var icExplicitCheck: UIImageView!
    @IBOutlet weak var viewAddAudio: UIView!
    @IBOutlet weak var colFilters: UICollectionView!
    
    //MARK: - Variables
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    @objc var selectedImage: UIImage!
    var arrOptions: [[String : Any]] = [["icon": "icImage", "iconSel": "icImageSel", "title": "Image"], ["icon": "icEffect", "iconSel": "icEffectSel", "title": "Effects"], ["icon": "icText", "iconSel": "icTextSel", "title": "Text"], ["icon": "icVideo", "iconSel": "icVideoSel", "title": "Video"]]
    var selectedOption: Int = -1
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(imageChanged(_:)), name: NSNotification.Name(rawValue: "ImageChanged"), object: nil)
        
        colFilters.register(UINib(nibName: "FilterCollectionCell", bundle: nil), forCellWithReuseIdentifier: "FilterCollectionCell")
        imgSelected.image = selectedImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let space1 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space1.width = 60
        let btnProject = UIBarButtonItem(image: #imageLiteral(resourceName: "icFolder"), style: .plain, target: self, action: #selector(actionButtonProject(_:)))
        let btnUndo = UIBarButtonItem(image: #imageLiteral(resourceName: "icUndo"), style: .plain, target: self, action: #selector(actionButtonUndo(_:)))
        self.navigationItem.addMutipleItemsToLeft(items: [btnProject, space1, btnUndo])
        
        let space2 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space2.width = 60
        let btnLayers = UIBarButtonItem(image: #imageLiteral(resourceName: "icLayers"), style: .plain, target: self, action: #selector(actionButtonLayers(_:)))
        let btnNext = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(actionButtonNext(_:)))
        btnNext.tintColor = .white
        self.navigationItem.addMutipleItemsToRight(items: [btnNext, space2, btnLayers])
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    //MARK: - Button Action Methods
    @objc func imageChanged(_ notification: NSNotification) {
        if let photo = notification.object as? UIImage {
            selectedImage = photo
            imgSelected.image = photo
        }
    }
    
    @objc func actionButtonProject(_ sender: UIButton) {
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "ProjectVC") as! ProjectVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func actionButtonUndo(_ sender: UIButton) {
        
    }
    
    @objc func actionButtonLayers(_ sender: UIButton) {
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "LayersVC") as! LayersVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func actionButtonNext(_ sender: UIButton) {
        
    }
    
    @IBAction func actionButtonExplicitContent(_ sender: UIButton) {
        icExplicitCheck.isHighlighted = !icExplicitCheck.isHighlighted
    }
    
    @IBAction func actionButtonAddAudio(_ sender: UIButton) {
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "SelectAudioVC") as! SelectAudioVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension FirstVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/4, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionCell", for: indexPath) as! FilterCollectionCell
        if indexPath.item == selectedOption {
            cell.imgIcon.image = UIImage(named: (arrOptions[indexPath.item])["iconSel"] as? String ?? "")
            cell.lblTitle.textColor = #colorLiteral(red: 0.8980392157, green: 0.4901960784, blue: 0, alpha: 1)
        } else {
            cell.imgIcon.image = UIImage(named: (arrOptions[indexPath.item])["icon"] as? String ?? "")
            cell.lblTitle.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        cell.lblTitle.text = (arrOptions[indexPath.item])["title"] as? String
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewAddAudio.isHidden = true
        selectedOption = -1
        
        switch indexPath.item {
        case 0:
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "StartPageViewController") as! StartPageViewController
            vc.isSelectingImage = true
            self.present(vc, animated: true, completion: nil)
            break
        case 1:
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "ImageFiltersVC") as! ImageFiltersVC
            vc.originalImage = imgSelected.image
            vc.actionCompletionBlock = {(image) in
                self.imgSelected.image = image
                self.selectedImage = image
            }
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 2:
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "TextFilterVC") as! TextFilterVC
            vc.selectedImage = imgSelected.image
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 3:
            viewAddAudio.isHidden = false
            selectedOption = indexPath.item
            break
        default:
            break
        }
        
        colFilters.reloadData()
    }
}
