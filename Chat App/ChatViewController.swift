//
//  ChatViewController.swift
//  Chat App
//
//  Created by Shourya Khare on 1/21/17.
//  Copyright © 2017 Shourya Khare. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    
    
    var root: FIRDatabaseReference!
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        root = FIRDatabase.database().reference()
        
        loadMessages()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardDidAppear(_ :)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardDidDisappear), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        var gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.gestureRecognized(gesture:)))
        self.view.addGestureRecognizer(gestureRecognizer)
        
        tableView.transform = CGAffineTransform(rotationAngle: -CGFloat(M_PI))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMessages() {
        let messageRef = root.child("messages")
        messageRef.queryOrdered(byChild: "date").observe(.childAdded, with: { snapshot in
            if let value = snapshot.value as! [String: Any]? {
                
                let timeInterval = value["date"] as! TimeInterval
                let text = value["text"] as! String
                let date = Date(timeIntervalSince1970: timeInterval)
                let message = Message(text: text, date: date)
                self.messages.append(message)
                self.tableView.reloadData()
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        }

    func gestureRecognized(gesture: UITapGestureRecognizer) {
        let touchPosition = gesture.location(in: self.view)
        if !bottomView.bounds.contains(touchPosition) {
            textField.resignFirstResponder()
        }

    }
    
    func keyboardDidAppear(_ notification: Notification) {
        if let userInfo = notification.userInfo, let frame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let constant = frame.height
            
            if bottomConstraint.constant == constant { return }
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
                self.bottomConstraint.constant = constant
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    func keyboardDidDisappear() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func UIButton(_ sender: Any) {
        if let text = textField.text {
            let messagesRef = root.child("messages")
            
            let date = Date()
            
            let message: [String: Any] = [
                "date": date.timeIntervalSince1970,
                "text": text
            ]
            messagesRef.childByAutoId().setValue(message)
        }
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell")
        
        let message = messages[messages.count - 1 - indexPath.row]
        let dateString = message.date.formattedString()
        let text = message.text
        
        cell?.textLabel?.text = text
        cell?.detailTextLabel?.text = dateString
        
        cell?.transform = CGAffineTransform(rotationAngle: -CGFloat(M_PI))
        
        return cell!
    }
}

extension Date {
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy, h:mm a"
        
        return formatter.string(from: self)
    }
}
