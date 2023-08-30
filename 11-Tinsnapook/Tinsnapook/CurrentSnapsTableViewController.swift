//
//  CurrentSnapsTableViewController.swift
//  Tinsnapook
//
//  Created by Juan Gabriel Gomila Salas on 17/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class CurrentSnapsTableViewController: UITableViewController {

    var snapsReceived = [Snap]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

         self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(returnPressed))
        
            print(AuthService.shared.user!.uid)
        DatabaseService.shared.usersRef.child(AuthService.shared.user!.uid).child("snapsReceived").observeSingleEvent(of: .value) { (snapshot:DataSnapshot) in
            
            if let currentSnaps = snapshot.value as? [String]{
                for snapKey in currentSnaps {
                    let snap = Snap(uid: snapKey, snapOrder : self.snapsReceived.count)
                    self.snapsReceived.append(snap)
                }
                self.downloadSnapInfo()
                self.tableView.reloadData()
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func downloadSnapInfo(){
        for var snap in self.snapsReceived {
            DatabaseService.shared.snapsRef.child(snap.uid).observeSingleEvent(of: .value){
                (snapshot: DataSnapshot) in
                if let data = snapshot.value as? Dictionary<String, AnyObject>{
                    if let mediaURL = data["mediaURL"] as? String {
                        snap.mediaURL = mediaURL
                        let httpRef = Storage.storage().reference(forURL: mediaURL)
                        
                        httpRef.getData(maxSize: 5 * 1024 * 1024, completion: { (data, error) in
                            if error != nil {
                                print("No se ha podido descargar la imagen \(snap.snapOrder)")
                            } else {
                                snap.mediaData = data
                                self.reloadSnap(snap)
                            }
                        })
                        
                    }
                    if let message = data["message"] as? String {
                        snap.message = message
                    }
                    if let openCount = data["openCount"] as? Int {
                        snap.openCount = openCount
                    }
                    if let receivers = data["receivers"] as? Dictionary<String, Bool>{
                        for receiver in receivers.keys{
                            snap.receivers.append(TinsnapookUser(uid: receiver, firstName:"", lastName:""))
                        }
                    }
                    if let textSnippet = data["textSnippet"] as? String {
                        snap.textSnippet = textSnippet
                    }
                    if let timeStamp = data["timeStamp"] as? String {
                        snap.timeStamp = timeStamp
                    }
                    if let userID = data["userID"] as? String {
                        var sender = TinsnapookUser(uid: userID, firstName: "John", lastName: "Doe")
                        snap.sender = sender
                        DatabaseService.shared.usersRef.child(userID).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                            if let data = snapshot.value as? Dictionary<String, AnyObject>{
                                var username = ""
                                if let firstName = data["firstName"] as? String {
                                    username.append(firstName+" ")
                                }
                                if let lastName = data["lastName"] as? String {
                                    username.append(lastName)
                                }
                                sender.username = username
                                snap.sender = sender
                                self.reloadSnap(snap)
                            }
                        })
                    }
                    self.reloadSnap(snap)
                }
            }
        }
    }
    
    func reloadSnap(_ snap: Snap){
        self.snapsReceived[snap.snapOrder] = snap
        self.tableView.reloadRows(at: [IndexPath(row: snap.snapOrder, section: 0)], with: .fade)
    }
    
    @objc func returnPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.snapsReceived.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SnapCell", for: indexPath) as! SnapTableViewCell

        let snap = self.snapsReceived[indexPath.row]
        
        cell.usernameLabel?.text = snap.uid
        
        if let name = snap.sender?.username {
            cell.usernameLabel?.text = name
        }
   
        if let date = snap.timeStamp {
            cell.timeStampLabel?.text = date
        }
        
        if let imageData = snap.mediaData {
            cell.snapImageView?.image = UIImage(data: imageData)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
