//
//  UsersTableViewController.swift
//  Tinsnapook
//
//  Created by Juan Gabriel Gomila Salas on 15/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class UsersTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var imageData : Data?
    var videoURL  : URL?
    
    @IBOutlet weak var tableView: UITableView!
    
    private var users = [TinsnapookUser]()
    private var selectedUsers = Dictionary<String, TinsnapookUser>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsMultipleSelection = true
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        DatabaseService.shared.usersRef.observeSingleEvent(of: .value) { (snapshot:DataSnapshot) in
            
            
            if let users = snapshot.value as? Dictionary<String, AnyObject> {
                for (key, value) in users {
                    if let dict = value as? Dictionary<String, AnyObject> {
                        if let profile = dict["profile"] as? Dictionary<String, AnyObject> {
                            if let firstName = profile["firstName"] as? String,
                                let lastName = profile["lastName"] as? String {
                                let uid = key
                                let user = TinsnapookUser(uid: uid, firstName: firstName, lastName: lastName)
                                self.users.append(user)
                            }
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
        
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.users.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
        let user = self.users[indexPath.row]
        cell.updateUserUI(user: user)
     return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
        cell.setCheckMark(selected: true)
        
        let user = self.users[indexPath.row]
        self.selectedUsers[user.uid] = user
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
        cell.setCheckMark(selected: false)
        
        let user = self.users[indexPath.row]
        self.selectedUsers[user.uid] = nil
        
        if self.selectedUsers.count <= 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    @IBAction func sendSnap(_ sender: UIBarButtonItem) {
        
        if let url = videoURL {
        
            let videoName = "\(UUID().uuidString)\(url)"
            let ref = DatabaseService.shared.videoStorageRef.child(videoName)
            _ = ref.putFile(from: url, metadata: nil, completion: { (metadata: StorageMetadata?, error: Error?) in
                if error != nil {
                    print("Error al subir el vídeo: \(error?.localizedDescription)")
                } else {
                    metadata?.storageReference?.downloadURL(completion: { url, error in
                        DatabaseService.shared.sendSnap(
                            senderUID: Auth.auth().currentUser!.uid,
                            receivers: self.selectedUsers,
                            mediaURL: url!,
                            textSnippet: "Programar con Firebase ha molado mucho!!")
                    })
                    
                    

                }
            })
            
        } else if let data = imageData {
            
            let imageName = "\(UUID().uuidString).jpg"
            let ref = DatabaseService.shared.imageStorageRef.child(imageName)
            
            _ = ref.putData(data, completion: { (metadata: StorageMetadata?, error: Error?) in
                if error != nil {
                    print("Error al subir la imagen: \(error?.localizedDescription)")
                } else {
                    let downloadURL = metadata?.storageReference?.downloadURL(completion: { url,error  in
                        DatabaseService.shared.sendSnap(
                            senderUID: Auth.auth().currentUser!.uid,
                            receivers: self.selectedUsers,
                            mediaURL: url!,
                            textSnippet: "Programar con Firebase ha molado mucho!!")
                    })

                    
                
                }
            })
        }
        
        
        
         self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
