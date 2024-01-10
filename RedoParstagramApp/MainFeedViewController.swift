//
//  MainFeedViewController.swift
//  RedoParstagramApp
//
//  Created by Nelson  on 11/15/23.
//

import UIKit
import Parse
import MessageInputBar

class MainFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    let commentBar = MessageInputBar()
    var showCommentBar = false
    var selectedPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        
        commentBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive

        // Do any additional setup after loading the view.
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
    }
    
    @IBAction func logoutBtnClick(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "loginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let
                delegate = windowScene.delegate as? SceneDelegate else { return }
        delegate.window? .rootViewController = loginViewController
    }
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        let comment = PFObject(className: "Comments")
        comment["post"] = selectedPost
        comment["user"] = PFUser.current()
        comment["text"] = text
        
        selectedPost.add(comment, forKey: "comment")
        
        selectedPost.saveInBackground{( success, error)in
            if error == nil{
                print("Comment saved")
            }else{
                print("Error saving comment")
            }
            
        }
        
        
        commentBar.inputTextView.text = nil
        tableView.reloadData()
        showCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className:"Posts")
        query.includeKeys(["user", "comment", "comment.user"])

        query.findObjectsInBackground { (feedPosts, error) in
            if feedPosts != nil {
                self.posts = feedPosts!
                self.tableView.reloadData()
            } else {
                print("Error \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let post = posts[indexPath.section]
        let comment = (post["comment"] as? [PFObject]) ?? []
        
        selectedPost = post
        
        if indexPath.row == comment.count + 1 {
            showCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
        }
//
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let post = posts[section]
        let comments = (post["comment"] as? [PFObject]) ?? []
//        print(comments)
//        print(comments.count)
        return comments.count + 2           // total = number of comments + origin post
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comment"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            let user = post["user"] as! PFUser
            
            cell.usernameLabel.text = user.username
            
            cell.PostCaptionLabel.text = (post["caption"] as! String)
            
            let imageFile =  post["image"] as! PFFileObject
            let urlString = imageFile.url
            let url = URL(string: urlString!)
            
            cell.photoView.af.setImage(withURL: url!)
            return cell
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
                
            let comment = comments[indexPath.row - 1]
            let user = comment["user"] as! PFUser
            
            cell.usernameLabel.text = user.username
            cell.commentLabel.text = comment["text"] as? String
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
