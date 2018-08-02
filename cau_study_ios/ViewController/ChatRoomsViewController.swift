//
//  ChatRoomsViewController.swift
//  cau_study_ios
//
//  Created by 신형재 on 30/07/2018.
//  Copyright © 2018 신형재. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ChatRoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    var uid: String!
    var chatrooms : [ChatModel]! = []
    var destinationUsers : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.uid = Auth.auth().currentUser?.uid
        self.getChatroomsList()
        // Do any additional setup after loading the view.
    }
    
    func getChatroomsList(){
        Database.database().reference().child("chatRooms").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
            self.chatrooms.removeAll()
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                
                if let chatroomdic = item.value as? [String:AnyObject]{
                    let chatModel = ChatModel(JSON: chatroomdic)
                    self.chatrooms.append(chatModel!)
                }
            }
            //테이블뷰 갱신코드
            self.tableview.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatrooms.count
    }
    
    //어떤 뷰를 쓸껀지
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for: indexPath) as! CustomCell
        
        var destinationUid : String?
        
        for item in chatrooms[indexPath.row].users{
            if(item.key != self.uid){
                destinationUid = item.key
                destinationUsers.append(destinationUid!)
            }
        }
        
       //setvalueForKeys swift용으로 대체
       /* Database.database().reference().child("users").child(destinationUid!).observeSingleEvent(of: DataEventType.value, with: {
            (datasnapshot) in
            var user = User()
            let user = datasnapshot.value as! [String:AnyObject]
            */
        
        Api.User.observeUser(withId: destinationUid!, completion: { user in
            var userModel = User()
            userModel = user
            //왜 되는지 모르곘음;;;;
            cell.label_title.text = userModel.username
            let url = URL(string: userModel.profileImageUrl!)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, err) in
                DispatchQueue.main.sync{
                    cell.imageview.image = UIImage(data:data!)
                    cell.imageview.layer.cornerRadius = cell.imageview.frame.width/2
                    cell.imageview.layer.masksToBounds = true
                }
            }).resume()
            
            //마지막 메세지를 띄어주는 코드
            let lastMessageKey = self.chatrooms[indexPath.row].comments.keys.sorted(){$0>$1}
            //오름차순: {$0>$1} 내림차순 : {$0<$1}
            cell.label_lastmessage.text = self.chatrooms[indexPath.row].comments[lastMessageKey[0]]?.message
            let unixTime = self.chatrooms[indexPath.row].comments[lastMessageKey[0]]?.timestamp
            cell.label_timestamp.text = unixTime?.toDayTime
        })
        
        return cell
    }
    
    //테이블뷰를 클릭할때 발생되는 이벤트
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //클릭하면 회색이되었다가 사라지게하는 코드
        tableView.deselectRow(at: indexPath, animated: true)
        let destinationUid = self.destinationUsers[indexPath.row]
        let view = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        view.destinationUid = destinationUid
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //다시로딩
        viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
