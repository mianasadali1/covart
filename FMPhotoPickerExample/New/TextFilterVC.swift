//
//  TextFilterVC.swift
//  FMPhotoPickerExample
//
//  Created by Apple on 11/09/21.
//  Copyright © 2021 Tribal Media House. All rights reserved.
//

import UIKit

class TextFilterVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var imgSelected: UIImageView!
    @IBOutlet weak var colOptions: UICollectionView!
    @IBOutlet weak var colFilters: UICollectionView!
    @IBOutlet weak var viewWatermark: UIView!
    @IBOutlet weak var viewAlignment: UIView!
    
    //MARK: - Variables
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var selectedImage: UIImage!
    var selectedOption: Int = 0
    var selectedFilter: Int = 0
    var arrOptions: [[String : Any]] = [["icon": "icTextStyle", "iconSel": "icTextStyleSel", "title": "Style"], ["icon": "icTextColor", "iconSel": "icTextColorSel", "title": "Color"], ["icon": "icTextWatermark", "iconSel": "icTextWatermarkSel", "title": "Watermark"], ["icon": "icShadow", "iconSel": "icShadowSel", "title": "Shadow"], ["icon": "icTextAlign", "iconSel": "icTextAlignSel", "title": "Align"]]
    var arrFilters: [UIImage] = [#imageLiteral(resourceName: "icColorPalette"), #imageLiteral(resourceName: "icColorDrop"), #imageLiteral(resourceName: "icSelectColor"), #imageLiteral(resourceName: "icSelectedColor")]
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        colOptions.register(UINib(nibName: "FilterCollectionCell", bundle: nil), forCellWithReuseIdentifier: "FilterCollectionCell")
        colFilters.register(UINib(nibName: "ImageFilterColCell", bundle: nil), forCellWithReuseIdentifier: "ImageFilterColCell")
        imgSelected.image = selectedImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.addLeftButtonWithImage(self, action: #selector(actionButtonCancel(_:)), buttonImage: #imageLiteral(resourceName: "icCancel"))
        
        let space1 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space1.width = 60
        let btnCancel = UIBarButtonItem(image: #imageLiteral(resourceName: "icCancel"), style: .plain, target: self, action: #selector(actionButtonCancel(_:)))
        let btnUndo = UIBarButtonItem(image: #imageLiteral(resourceName: "icUndo"), style: .plain, target: self, action: #selector(actionButtonUndo(_:)))
        self.navigationItem.addMutipleItemsToLeft(items: [btnCancel, space1, btnUndo])
        
        let space2 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space2.width = 60
        let btnLayers = UIBarButtonItem(image: #imageLiteral(resourceName: "icLayers"), style: .plain, target: self, action: #selector(actionButtonLayers(_:)))
        let btnConfirm = UIBarButtonItem(image: #imageLiteral(resourceName: "icConfirm"), style: .plain, target: self, action: #selector(actionButtonConfirm(_:)))
        self.navigationItem.addMutipleItemsToRight(items: [btnConfirm, space2, btnLayers])
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    //MARK: - Button Action Methods
    @objc func actionButtonCancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func actionButtonUndo(_ sender: UIButton) {
        
    }
    
    @objc func actionButtonLayers(_ sender: UIButton) {
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "LayersVC") as! LayersVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func actionButtonConfirm(_ sender: UIButton) {
        colOptions.isHidden = false
    }
    
    @IBAction func actionButtonAddWatermark(_ sender: UIButton) {
    }
}

extension TextFilterVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colOptions {
            return arrOptions.count
        } else {
            return arrFilters.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == colOptions {
            return CGSize(width: collectionView.frame.size.width/4, height: collectionView.frame.size.height)
        } else {
            return CGSize(width: collectionView.frame.size.width/4.5, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == colOptions {
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
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageFilterColCell", for: indexPath) as! ImageFilterColCell
            
            switch selectedOption {
            case 0:
                if selectedFilter == indexPath.item {
                    cell.imgFilter.image = #imageLiteral(resourceName: "icFontSel")
                } else {
                    cell.imgFilter.image = #imageLiteral(resourceName: "icFont")
                }
                cell.imgFilter.contentMode = .scaleAspectFit
                break
            case 1:
                cell.imgFilter.image = arrFilters[indexPath.item]
                cell.imgFilter.contentMode = .scaleAspectFit
                break
            default:
                break
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colOptions {
            selectedOption = indexPath.item
            if selectedOption == 2 {
                colFilters.isHidden = true
                viewWatermark.isHidden = false
                viewAlignment.isHidden = true
            } else if selectedOption == 3 {
                colFilters.isHidden = true
                viewWatermark.isHidden = true
                viewAlignment.isHidden = true
            } else if selectedOption == 4 {
                colFilters.isHidden = true
                viewWatermark.isHidden = true
                viewAlignment.isHidden = false
            } else {
                colFilters.isHidden = false
                viewWatermark.isHidden = true
            }
        } else {
            selectedFilter = indexPath.item
        }
        
        colOptions.reloadData()
        colFilters.reloadData()
    }
}
