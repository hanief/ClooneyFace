//
//  DrawerViewController.swift
//  ClooneyFace
//
//  Created by Hanief on 10/03/2018.
//  Copyright © 2018 Ruminant Ablutionist. All rights reserved.
//

import UIKit
import Pulley
import SafariServices

class DrawerViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var gripperView: UIView!
    @IBOutlet var topSeparatorView: UIView!
    @IBOutlet var bottomSeperatorView: UIView!
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var loadingAnimation: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet var gripperTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var clooneyStackView: UIStackView!
    @IBOutlet weak var clooneyImageView: UIImageView!
    @IBOutlet weak var clooneySentence: UILabel!
    @IBOutlet weak var clooneyPercentage: UILabel!
    
    var clooneyStatus: Dictionary = [
        "success": [
            "image": "clooney-success",
            "sentence": "Brilliant!",
            "percentage": 100.0
        ],
        "notbad": [
            "image": "clooney-notbad",
            "sentence": "Not bad",
            "percentage": 75.0
        ],
        "isitme": [
            "image": "clooney-me",
            "sentence": "What else?",
            "percentage": 50.0
        ],
        "failed": [
            "image": "clooney-failed",
            "sentence": "That's not me!",
            "percentage": 25.0
        ],
    ]
    
    // We adjust our 'header' based on the bottom safe area using this constraint
    @IBOutlet var headerSectionHeightConstraint: NSLayoutConstraint!
    
    fileprivate var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
            
            // We'll configure our UI to respect the safe area. In our small demo app, we just want to adjust the contentInset for the tableview.
            tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        gripperView.layer.cornerRadius = 2.5
        
        FaceObserved.shared.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // You must wait until viewWillAppear -or- later in the view controller lifecycle in order to get a reference to Pulley via self.parent for customization.
        
        // UIFeedbackGenerator is only available iOS 10+. Since Pulley works back to iOS 9, the .feedbackGenerator property is "Any" and managed internally as a feedback generator.
        if #available(iOS 10.0, *)
        {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            (self.parent as? PulleyViewController)?.feedbackGenerator = feedbackGenerator
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // The bounce here is optional, but it's done automatically after appearance as a demonstration.
//        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(bounceDrawer), userInfo: nil, repeats: false)
    }
    
    @objc fileprivate func bounceDrawer() {
        
        // We can 'bounce' the drawer to show users that the drawer needs their attention. There are optional parameters you can pass this method to control the bounce height and speed.
        (self.parent as? PulleyViewController)?.bounceDrawer()
    }
}

extension DrawerViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 60.0 + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 264.0 + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all// You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
    }
    
    // This function is called by Pulley anytime the size, drawer position, etc. changes. It's best to customize your VC UI based on the bottomSafeArea here (if needed).
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat)
    {
        // We want to know about the safe area to customize our UI. Our UI customization logic is in the didSet for this variable.
        drawerBottomSafeArea = bottomSafeArea
        
        /*
         Some explanation for what is happening here:
         1. Our drawer UI needs some customization to look 'correct' on devices like the iPhone X, with a bottom safe area inset.
         2. We only need this when it's in the 'collapsed' position, so we'll add some safe area when it's collapsed and remove it when it's not.
         3. These changes are captured in an animation block (when necessary) by Pulley, so these changes will be animated along-side the drawer automatically.
         */
        if drawer.drawerPosition == .collapsed
        {
            headerSectionHeightConstraint.constant = 68.0 + drawerBottomSafeArea
        }
        else
        {
            headerSectionHeightConstraint.constant = 68.0
        }
        
        // Handle tableview scrolling / searchbar editing
        
        tableView.isScrollEnabled = drawer.drawerPosition == .open || drawer.currentDisplayMode == .leftSide
        
        
        if drawer.currentDisplayMode == .leftSide
        {
            topSeparatorView.isHidden = drawer.drawerPosition == .collapsed
            bottomSeperatorView.isHidden = drawer.drawerPosition == .collapsed
        }
        else
        {
            topSeparatorView.isHidden = false
            bottomSeperatorView.isHidden = true
        }
    }
    
    /// This function is called when the current drawer display mode changes. Make UI customizations here.
    func drawerDisplayModeDidChange(drawer: PulleyViewController) {
        
        print("Drawer: \(drawer.currentDisplayMode)")
        gripperTopConstraint.isActive = drawer.currentDisplayMode == .bottomDrawer
    }
}

extension DrawerViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if let drawerVC = self.parent as? PulleyViewController
        {
            drawerVC.setDrawerPosition(position: .open, animated: true)
        }
    }
}

extension DrawerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FaceObserved.shared.persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as? PersonTableViewCell {
        
            let person = FaceObserved.shared.persons[indexPath.row]
            
            cell.nameLabel?.text = person.name
            cell.bioLabel?.text = person.bio
            cell.webURL = person.website
            cell.twitterAccount = person.twitter
            cell.linkedInAccount = person.linkedIn
            cell.imageURL = person.faceURL
            cell.delegate = self
        
            return cell
        }
        
        return UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
    }
}

extension DrawerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DrawerViewController: FaceObservedDelegate {
    func didUpdatedDetection() {
        
    }
    
    func didUpdatePerson() {

        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
            self.loadingAnimation.stopAnimating()
            
            if let drawerVC = self.parent as? PulleyViewController
            {
                drawerVC.setDrawerPosition(position: .partiallyRevealed, animated: true)
            }
        }
    }
    
    func didLoadClooney() {
        var status = "success"
        
        let confidence = FaceObserved.shared.clooneyConfidence
        
        if confidence < 0.10 {
            status = "failed"
        } else if confidence < 0.20 {
            status = "isitme"
        } else if confidence < 0.40 {
            status = "notbad"
        }
        
        if let clooneyDic = self.clooneyStatus[status] {
            DispatchQueue.main.async {
                self.clooneyImageView.image = UIImage(named: clooneyDic["image"] as! String)
                self.clooneyImageView.isHidden = false
                self.clooneySentence.text = clooneyDic["sentence"] as! String
                self.clooneySentence.isHidden = false
                let percent = FaceObserved.shared.clooneyConfidence * 100
                self.clooneyPercentage.text = "\(percent)% its Clooney"
                
                self.clooneyPercentage.isHidden = false
            }
        }
    }
    
    
    func didUpdatePreviewImage() {
        self.previewImageView.image = FaceObserved.shared.previewImage
    }
    
    func didStartLoading() {
        DispatchQueue.main.async {
            self.loadingAnimation.startAnimating()
        }
    }
    
    func didStopLoading() {
        DispatchQueue.main.async {
            self.loadingAnimation.stopAnimating()
        }
    }
}

extension DrawerViewController: PersonTableViewCellDelegate {
    func didTapWebButtonOnCell(_ cell: PersonTableViewCell) {
        print(cell.webURL)
        
        if let url = URL(string: "http://" + cell.webURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func didTapTwitterButtonOnCell(_ cell: PersonTableViewCell) {
        print(cell.twitterAccount)
        
        if let url = URL(string: "http://twitter.com/" + cell.twitterAccount.replacingOccurrences(of: "@", with: "")) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func didTapLinkedInButtonOnCell(_ cell: PersonTableViewCell) {
        print(cell.linkedInAccount)
        
        if let url = URL(string: "http://" + cell.linkedInAccount) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
