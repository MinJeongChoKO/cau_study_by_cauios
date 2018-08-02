//
//  ExploreTableViewCell.swift
//  cau_study_ios
//
//  Created by Davee on 2018. 3. 20..
//  Copyright © 2018년 신형재. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol ExploreTableViewCellDelegate {
    func goToPostVC(postId: String)
}

class ExploreTableViewCell: UITableViewCell {

    @IBOutlet weak var exploreTitleLabel: UILabel!
    @IBOutlet weak var exploreTagsLabel: UILabel!
    @IBOutlet weak var savedLikeImageView: UIImageView!
    @IBOutlet weak var exploreCateImageView: UIImageView!
    
    //[0731 Dahye] Add outlets
    
    @IBOutlet weak var exploreUnameLabel: UILabel!
    @IBOutlet weak var exploreTimestampLabel: UILabel!
    
    var delegate: ExploreTableViewCellDelegate?
    
    // [Dahye Comment] didSet is an obsever. We can group all methods that require this post instance as an input in this observer.
    // [Dahye 05.20] We must set didSet observer to conveniently update a cell, when there is an updated data.
    var posts = [Post]()

    var post: Post? {
        didSet {
         
            updateView()
        }
    }
    
    
    
    // [Dahye Comment] Fetch newly posting data from FB
    func updateView() {
        exploreTitleLabel.text = post?.title
        exploreTagsLabel.text = post?.tags
        
        // [0731 Dahye] for category image
        if post?.category == "학업" {
            exploreCateImageView?.image = #imageLiteral(resourceName: "catstu")
        }
        if post?.category == "취업" {
            exploreCateImageView?.image = #imageLiteral(resourceName: "catjob")
        }
        if post?.category == "어학" {
            exploreCateImageView?.image = #imageLiteral(resourceName: "catlan")
        }
  
        
        
        let tapGestureForExploreTitleLabel = UITapGestureRecognizer(target: self, action: #selector(self.exploreTitleLabel_TouchUpInside))
        
    exploreTitleLabel.addGestureRecognizer(tapGestureForExploreTitleLabel)
        exploreTitleLabel.isUserInteractionEnabled = true
        
        let tapGestureForSavedLikeImageView =
            UITapGestureRecognizer(target: self, action: #selector(self.savedLikeImageView_TouchUpInside))
            savedLikeImageView.addGestureRecognizer(tapGestureForSavedLikeImageView)
                savedLikeImageView.isUserInteractionEnabled = true
        
        if let currentUser = Auth.auth().currentUser {
            Api.User.REF_USERS.child(currentUser.uid).child("saved").child(post!.id!).observeSingleEvent(of: .value) { snapshot in
                if let _ = snapshot.value as? NSNull {
                    self.savedLikeImageView.image = UIImage(named: "like")
                } else {
                    self.savedLikeImageView.image = UIImage(named: "likeSelected")
                    
                }
            }
         
        

    }
    }
    // hohyun Comment saved like button activate!
 
    @objc func savedLikeImageView_TouchUpInside(){
        if let currentUser = Auth.auth().currentUser {
            Api.User.REF_USERS.child(currentUser.uid).child("saved").child(post!.id!).observeSingleEvent(of: .value) { snapshot in
                if let _ = snapshot.value as? NSNull {
                    Api.User.REF_USERS.child(currentUser.uid).child("saved").child(self.post!.id!).setValue(true)
                    self.savedLikeImageView.image = UIImage(named: "likeSelected")
                    Api.Saved.REF_SAVED.child(currentUser.uid).child(self.post!.id!).setValue(true)
                    
                    
                }
                else {
                    Api.User.REF_USERS.child(currentUser.uid).child("saved").child(self.post!.id!).removeValue()
                    self.savedLikeImageView.image = UIImage(named: "like")
                    Api.Saved.REF_SAVED.child(currentUser.uid).child(self.post!.id!).removeValue()
                    

                    
                }
            }
            
        }
        
    
    }
    
    
    @objc func exploreTitleLabel_TouchUpInside(){
        if let id = post?.id {
            delegate?.goToPostVC(postId: id)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
