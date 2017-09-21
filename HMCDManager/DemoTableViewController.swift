//
//  DemoTableViewController.swift
//  HMCDManager
//
//  Created by HuangZhongQing on 2017/9/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit
import CoreData

class DemoTableViewController: UITableViewController {
    //    保存名字的数组
    var names = [String]()
    
    var people = [NSManagedObject]()
    
    private var segment:UISegmentedControl = UISegmentedControl.init(items: ["person","group","message"])
    
    let cellIdentifier = "nameCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segment.frame = .init(x: 0, y: 0, width: 150, height: 44)
        segment.addTarget(self , action: #selector(self.segmentChange(sender:)), for: .valueChanged)
        segment.selectedSegmentIndex = 0
        self.navigationItem.titleView = segment
        
        let clearBt = UIBarButtonItem.init(title: "清除", style: .plain, target: self , action: #selector(self.clearAll))
        let switchDB = UIBarButtonItem.init(title: "切换数据库", style: .plain, target: self , action: #selector(self.switchDBClick))
        self.navigationItem.leftBarButtonItems = [clearBt,switchDB]
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.requestAndRelaod()
    }
    
    func switchDBClick(){
        if HMCDManager.shared.userDBName == ""{
            HMCDManager.shared.userDBName = "user3"
        }else{
            HMCDManager.shared.userDBName = ""
        }
        
        self.requestAndRelaod()
    }
    
    func segmentChange(sender:UISegmentedControl){
        self.requestAndRelaod()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return people.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let obj = people[indexPath.row]
        
        if let person:Person = obj as? Person{
            cell.textLabel?.text = "person name:\(person.name!)  id:\(person.uid)"
        }else if let group:Group = obj as? Group{
            cell.textLabel?.text = "group name:\(group.name!)  id:\(group.id)"
        }else if let msg:Message = obj as? Message {
            cell.textLabel?.text = "msg sender:\(msg.senderID)  \(msg.msgContent)"
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let obj = people[indexPath.row]
        
        obj.db_delete { (error ) in
            if error == nil {
                self.people.remove(at: self.people.index(of: obj)!)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }else{
                print("delete error :\(error!)")
            }
        }
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = people[indexPath.row]
        let alert = UIAlertController(title: "修改姓名", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "保存", style: .default) { (action :UIAlertAction!) in
            let textField = alert.textFields![0] as UITextField
            if self.segment.selectedSegmentIndex == 2 {
                obj.db_update(values: ["msgContent":textField.text ?? ""], success: { (person ) in
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }) { (error ) in
                    print("update failure :\(error)")
                }
            }else {
                obj.db_update(values: ["name":textField.text ?? ""], success: { (person ) in
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }) { (error ) in
                    print("update failure :\(error)")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action: UIAlertAction) in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { (textField: UITextField) in
            if obj is Message{
                textField.text = (obj as! Message).msgContent
            }else{
                textField.text = obj.value(forKey: "name") as? String
            }
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func requestAndRelaod(){
        if segment.selectedSegmentIndex == 0 {
            self.requestPersonAndReload()
        }else if segment.selectedSegmentIndex == 1 {
            self.requestGroupsAndReload()
        }else {
            self.requestMessageAndReload()
        }
    }
    
    func clearAll(){
        if segment.selectedSegmentIndex == 0 {
            Person.db_deleteAll(complettion: { (error) in
                if error != nil {
                    print("delete persons error :\(error!)")
                }else{
                    self.people.removeAll()
                    self.tableView.reloadData()
                }
            })
        }else {
            Group.db_deleteAll(complettion: { (error) in
                if error != nil {
                    print("delete groups error :\(error!)")
                }else{
                    self.people.removeAll()
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    private func requestPersonAndReload(){
        //        let predicate:NSPredicate = NSPredicate.init(format: "name LIKE %@", argumentArray: ["*一下*"])
        
        Person.db_query(predicate: nil , sortBy: nil, sortAscending: true , offset: 0, limitCount: 0, success: { (objs) in
            self.people = objs
            self.tableView.reloadData()
        }, failure: { (error ) in
            print("request Person error :\(error)")
        })
    }
    
    private func requestGroupsAndReload(){
        Group.db_query(predicate: nil , sortBy: nil, sortAscending: true , offset: 0, limitCount: 0, success: { (objs) in
            self.people = objs
            self.tableView.reloadData()
        }, failure: { (error ) in
            print("request Group error :\(error)")
        })
    }
    
    private func requestMessageAndReload(){
        
        Message.db_query(predicate: nil , sortBy: nil, sortAscending: true , offset: 0, limitCount: 0, success: { (objs) in
            self.people = objs
            self.tableView.reloadData()
        }, failure: { (error ) in
            print("request Message error :\(error)")
        })
    }
    
    @IBAction func addName(_ sender: Any) {
        let alert = UIAlertController(title: "添加姓名", message: "请输入一个名字", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "保存", style: .default) { (action :UIAlertAction!) in
            let textField = alert.textFields![0] as UITextField
            
            if self.segment.selectedSegmentIndex == 1 {
                
                if let group3333 = Group.newNotInertObj() as? Group{
                    group3333.name = "323423423dsfsdfsfssfs"
                }
                
                if let group:Group = Group.newObj() as? Group{
                    group.id = 3
                    group.name = textField.text ?? "default group name "
                    group.detail = "detail "
                    
                    group.db_update(completion: { (error) in
                        if error == nil  {
                            self.people.append(group)
                            self.tableView.reloadData()
                            
                        }else{
                            print("add group name failure:\(error!)")
                        }
                    })
                }
            }else if self.segment.selectedSegmentIndex == 0 {
                if let pers:Person = Person.newObj() as? Person{
                    pers.name = textField.text ?? "defailt person name"
                    
                    pers.db_update(completion: { (error) in
                        if error == nil  {
                            self.people.append(pers)
                            self.tableView.reloadData()
                        }else{
                            print("add group name failure:\(error!)")
                        }
                    })
                }
            }else {
                if let msg:Message = Message.newObj() as? Message{
                    msg.msgContent = textField.text ?? "defailt person name"
                    msg.msgID  = 333
                    msg.senderID = "sender3243"
                    
                    msg.db_update(completion: { (error) in
                        if error == nil  {
                            self.people.append(msg)
                            self.tableView.reloadData()
                        }else{
                            print("add group name failure:\(error!)")
                        }
                    })
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action: UIAlertAction) in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { (textField: UITextField) in
        }
        
        present(alert, animated: true, completion: nil)
        
    }
}
