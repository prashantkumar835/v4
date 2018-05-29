//
//  ViewController.swift
//  CollectionViewInsideTableView
//
//  Created by Madhuri kumari on 18/05/18.
//  Copyright © 2018 Yash Patel. All rights reserved.
//

import UIKit
import SQLite3
import Alamofire            //TO SERILISEZED DATA IN THE FORM OF JASON OBJECT
import SwiftyJSON           //TO RETRIVE DATA IN THHE ORIGINAL FORM FROM JASON OBJECT

struct Catt: Decodable {
    let _id: String?
    let name: String?
    let img: String?
    let pid: String?
    
    //    init(json: [String: Any]) {
    //                _id = json["_id"] as? Int ?? -1
    //                name = json["name"] as? String ?? ""
    //                img = json["img"] as? String ?? ""
    //                pid = json["pid"] as? Int ?? 1
    //            }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var candidate = Candidate()     //created an object of candidate
    var cats: [Catt]? = nil
    var dataIntoJason: JSON = nil
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var mytableView: UITableView!
    
    //@IBOutlet weak var myCollectionViewUnderTV: UICollectionView!
    
    let sections = ["politics", "sports", "news",  "entertement", "topten", "others"]
    
//    let subSection = [
//        ["Parti", "National", "State"],
//        ["Cricket", "Batmentan", "Tenish"],
//        ["Generlist", "Show", "News Channel", "News Paper"],
//        ["Actor", "Actoress", "Movies"],
//        ["Scientist", "RichestPerson",],
//        ["", "", ""]
//    ]
    
    lazy var catList = [Cat]()
    var personList = [Person]()
    var poleList = [Pole]()
    
    var db: OpaquePointer?  // DataBase Decleration
    var myDB: String = "myDB" // DataBase Name
    
    let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    var fileURL: URL? = nil
    
    var imageUrls = ["https://firebasestorage.googleapis.com/v0/b/our-leaders.appspot.com/o/Chidambaram.jpeg?alt=media&token=8edfede0-7389-430d-bf45-76d63f8a80f3","https://firebasestorage.googleapis.com/v0/b/our-leaders.appspot.com/o/kejriwal%20(1).jpg?alt=media&token=db83a84e-65ff-48f3-9f48-92e038849c54","https://firebasestorage.googleapis.com/v0/b/our-leaders.appspot.com/o/mamata%20(1).jpg?alt=media&token=52c23bb2-971f-4168-83ca-c199aae4e5a0","https://firebasestorage.googleapis.com/v0/b/our-leaders.appspot.com/o/Modi%20(1).jpg?alt=media&token=e7bd0650-db93-4810-923e-5682a1c3497e","https://firebasestorage.googleapis.com/v0/b/our-leaders.appspot.com/o/Modi.png?alt=media&token=b328397e-85b8-4ffb-a994-690b9bb85401","https://firebasestorage.googleapis.com/v0/b/our-leaders.appspot.com/o/Narendra%20Modi.jpeg?alt=media&token=56e438cc-0c0d-4e5a-9281-c4a5b89cd4ad","https://as.ftcdn.net/r/v1/pics/ea2e0032c156b2d3b52fa9a05fe30dedcb0c47e3/landing/images_photos.jpg"]
    
    
    lazy var queryToReadData = "select _id, name, img, pid from cat"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mytableView.delegate = self
        mytableView.dataSource = self
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        fileURL = documentDirectory.appendingPathComponent(myDB).appendingPathExtension("sqlite3") // DataBase File Directory
        
        createCatTable()
        creatPersonTable()
        creatPoleTable()
        
        serilzingDataFromServer()
        
        recoverCatData()
        
        //recoverPersonData()
        //recoverPoleData()
        
    }
    
    
    func serilzingDataFromServer() {
        
        ///-----------------Gatting data from surber-------------
        let jsonUrlString = "https://allnp.net/allpoll/getCat.php"
        
        //Convert the string url into url form (object)
        guard let url = URL(string: jsonUrlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            //perhaps check err
            //also perhaps check response status 200 OK
            
            guard let data = data else { return }
            
             /*
             //Give the data in string form
             let dataAsString = String(data: data, encoding: .utf8)
             print(dataAsString ?? "")
             */
            
            ///*
            //Give the data in serilised form
            Alamofire.request(jsonUrlString).responseJSON { response in
                if response.result.isSuccess{
                    print("Sucess! Got the Dta")
                    
                    self.dataIntoJason = JSON(response.result.value!)
                    
                    print(self.dataIntoJason)
                    
                    self.updateCatData(json: self.dataIntoJason) //TO UPDATE DATA
                }
                else{
                    print("Error \(response.result.error)")
                }
            }//*/
            
            do {
                
                //JSON Parsing
                ///*
                self.cats = try JSONDecoder().decode([Catt].self, from: data)
                //print(cats)
                //*/
                
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
            }.resume()
        ///-----------------Gatting data from surber end------------
        
    }
    
    
    func loadData() {
        // code to load data from network, and refresh the interface
        myCollectionView.reloadData()
        mytableView.reloadData()
    }

    func updateCatData(json: JSON){
        
        for i in 0..<cats!.count{
            
            candidate._id = json[i]["_id"].intValue
            candidate.name = json[i]["name"].stringValue
            candidate.img = json[i]["img"].stringValue
            candidate.pid = json[i]["pid"].intValue
            
            print(candidate._id, "\t"+candidate.name, "\t"+candidate.img, "\t", candidate.pid)
            print("---------------------------------------------------")
            //        print(candidate.name)
            //        print(candidate.img)
            //        print(candidate.pid)
            
            insertingDataToTableFromSurber()
            
        }
        
    }
    
    //Inserting Data to Table from serber
    func insertingDataToTableFromSurber() {
        
        openDatabase()
        
        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO cat (_id, name, img, pid) VALUES (?,?,?,?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 1, Int32(candidate._id)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 2, candidate.name, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 3, candidate.img, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 4, Int32(candidate.pid)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        print("**************cat saved successfully***********************")
        closeDatabase()
    }
    
    //Total Number Of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        //return 1
        return self.sections.count
    }
    
    //TITLE FOR HEADER IN A SECTION
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    //Total Number of Rows In Each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("numberOfRowsInSection = \(catList.count)")
        //return catList.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220 //heightForRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tcell", for: indexPath)
        //cell.textLabel?.text = catList[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let tableViewCell = cell as? CustomTableViewCell {
            tableViewCell.setCollectionViewdelegate(delegate: self, forRow: indexPath.row)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.myCollectionView {
            return 6
        }
        
        //print("numberOfItemsInSection = \(catList.count)")
        return catList.count
        //return 6
        
}


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //var cell: CollectionViewCell?
        
        if collectionView == self.myCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iccell", for: indexPath) as! IconCustomCollectionViewCell
            
            cell.iimageCell.image = UIImage(named: sections[indexPath.row])
            
            
//            let cat: Cat
//            cat = catList[indexPath.row]
//            //cell.labelHeading.text = cat.name?.capitalized
//
//
//            let imageView = cell.viewWithTag(1) as! UIImageView
//            //imageView.sd_setImage(with: URL(string: imageUrls[indexPath.row]))
//            imageView.sd_setImage(with: URL(string: cat.img!))

            //---------------*****------------------
            //imageView.sd_setImage(with: URL(string: cat.iurl!))
            //cell.imageCell.image = imageView.sd_imageURL(with: URL(string: imageUrls[indexPath.row]))
            //cell.imageCell.image = UIImage(named: imageUrls[indexPath.row])
            //-----------------XXXXX------------------

            //cell.labelHeading.text = imageUrls[indexPath.row].capitalized
            cell.layer.cornerRadius = cell.bounds.height / 20


            //----------------*******---------------------
            //cell.layoutIfNeeded()
            //cell.leaderImage.layer.cornerRadius = cell.leaderImage.frame.height/2
            //This creates the shadows and modifies the cards a little bit
            //-----------------XXXXX------------------


            cell.contentView.layer.cornerRadius = 0.0
            cell.contentView.layer.borderWidth = 0.0
            cell.contentView.layer.borderColor = UIColor.clear.cgColor
            cell.contentView.layer.masksToBounds = false
            cell.layer.shadowColor = UIColor.gray.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 0.0)
            cell.layer.shadowRadius = 30.0
            cell.layer.shadowOpacity = 0.0
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath

            return cell

        }
        else {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ccell", for: indexPath) as! CustomCollectionViewCell
            //return cell
            
        let cat: Cat
        cat = catList[indexPath.row]
        cell.labelHeading.text = cat.name?.capitalized
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        //imageView.sd_setImage(with: URL(string: imageUrls[indexPath.row]))
        imageView.sd_setImage(with: URL(string: cat.img!))

        //---------------*****------------------
        //imageView.sd_setImage(with: URL(string: cat.iurl!))
        //cell.imageCell.image = imageView.sd_imageURL(with: URL(string: imageUrls[indexPath.row]))
        //cell.imageCell.image = UIImage(named: imageUrls[indexPath.row])
        //-----------------XXXXX------------------
        
        //cell.labelHeading.text = imageUrls[indexPath.row].capitalized
        cell.layer.cornerRadius = cell.bounds.height / 20

        //----------------*******---------------------
        //cell.layoutIfNeeded()
        //cell.leaderImage.layer.cornerRadius = cell.leaderImage.frame.height/2
        //This creates the shadows and modifies the cards a little bit
        //-----------------XXXXX------------------

        cell.contentView.layer.cornerRadius = 4.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
            
        return cell
            
            
}
}
    
    //-----------------------Start--------SQLite-------------------------
    
    //To Open DataBase
    func openDatabase(){
        if sqlite3_open(fileURL?.path, &db) != SQLITE_OK {
            print("error opening database")
        }
    }
    
    
    //To Close DataBase
    func closeDatabase() {
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        //db = nil
    }
    
    
    //Create cat Table Inside myDB DataBase
    func createCatTable(){
        
        let catTableCreatQuary = "CREATE TABLE IF NOT EXISTS cat (_id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, img TEXT, pid INTEGER)"
        
        //fileURL = documentDirectory.appendingPathComponent(myDB).appendingPathExtension("sqlite3")
        
        print(fileURL!)
        
        openDatabase()
        
        if sqlite3_exec(db, catTableCreatQuary, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        print("**********creatCatTable()*************")
        closeDatabase()
    }
    
    //Create person Table Inside myDB DataBase
    func creatPersonTable() {
        
        let personTableCreatQuary = "CREATE TABLE IF NOT EXISTS person (_id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, info TEXT, img TEXT, cid INTEGER)"
        
        //fileURL = documentDirectory.appendingPathComponent(myDB).appendingPathExtension("sqlite3")
        
        print(fileURL!)
        
        openDatabase()
        
        if sqlite3_exec(db, personTableCreatQuary, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        print("**********creatPersonTable()*************")
        closeDatabase()
    }
    
    
    //Create Pole Table Inside myDB DataBase
    func creatPoleTable() {
        
        let poleTableCreatQuary = "CREATE TABLE IF NOT EXISTS pole (_id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, des TEXT, img TEXT, info TEXT, cid INTEGER)"
        
        //fileURL = documentDirectory.appendingPathComponent(myDB).appendingPathExtension("sqlite3")
        
        print(fileURL!)
        
        openDatabase()
        
        if sqlite3_exec(db, poleTableCreatQuary, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        print("**********creatPoleTable()*************")
        
        closeDatabase()
    }
    
    
    //Recover or retrive or Read data from Cat Table
    func recoverCatData() {
        
        openDatabase()
        
        var statement: OpaquePointer?
        //let query = "select _id, name, img, pid from cat"
        
        if sqlite3_prepare_v2(db, queryToReadData, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        //traversing through all the records
        while(sqlite3_step(statement) == SQLITE_ROW){
            let _id = sqlite3_column_int(statement, 0)
            let name = String(cString: sqlite3_column_text(statement, 1))
            let img = String(cString: sqlite3_column_text(statement, 2))
            let pid = sqlite3_column_int(statement, 3)
            
            //adding values to list
            catList.append(Cat(_id: Int(_id), name: String(describing: name), img: String(describing: img), pid: Int(pid)))
            print(catList.isEmpty)
        }
        
        /*//PRINTING DATA TO CONSOLE
         while sqlite3_step(statement) == SQLITE_ROW {
         
         let _id = sqlite3_column_int64(statement, 0)
         print("_id = \(_id); ", terminator: "")
         
         if let cString = sqlite3_column_text(statement, 1) {
         let name = String(cString: cString)
         print("name = \(name)")
         } else {
         print("name not found")
         }
         
         if let cString = sqlite3_column_text(statement, 2) {
         let img = String(cString: cString)
         print("img = \(img)")
         } else {
         print("img not found")
         }
         
         let pid = sqlite3_column_int64(statement, 3)
         print("pid = \(pid); ", terminator: "\n")
         
         }*/
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        
        print("**********recoverData()*************")
        closeDatabase()
        
    }
    
    
    //Recover or retrive data from Person Table
    func recoverPersonData() {
        
        openDatabase()
        
        var statement: OpaquePointer?
        let query = "select _id, name, info, img, cid from person"
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        //traversing through all the records
        while(sqlite3_step(statement) == SQLITE_ROW){
            let _id = sqlite3_column_int(statement, 0)
            let name = String(cString: sqlite3_column_text(statement, 1))
            let info = String(cString: sqlite3_column_text(statement, 2))
            let img = String(cString: sqlite3_column_text(statement, 3))
            let cid = sqlite3_column_int(statement, 4)
            
            //adding values to list
            personList.append(Person(_id: Int(_id), name: String(describing: name), info:String(describing: info), img: String(describing: img), cid: Int(cid)))
            print(personList.isEmpty)
        }
        
        /*//PRINTING DATA TO CONSOLE
         while sqlite3_step(statement) == SQLITE_ROW {
         
         let _id = sqlite3_column_int64(statement, 0)
         print("_id = \(_id); ", terminator: "")
         
         if let cString = sqlite3_column_text(statement, 1) {
         let name = String(cString: cString)
         print("name = \(name)")
         } else {
         print("name not found")
         }
         
         if let cString = sqlite3_column_text(statement, 2) {
         let infourl = String(cString: cString)
         print("info = \(info)")
         } else {
         print("info not found")
         }
         
         if let cString = sqlite3_column_text(statement, 3) {
         let img = String(cString: cString)
         print("img = \(img)")
         } else {
         print("img not found")
         }
         
         let cid = sqlite3_column_int64(statement, 4)
         print("cid = \(cid); ", terminator: "\n")
         
         }*/
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        
        print("**********recoverPersonData()*************")
        closeDatabase()
    }
    
    
    
    //Recover or retrive data from Pole Table
    func recoverPoleData() {
        
        openDatabase()
        
        var statement: OpaquePointer?
        
        let query = "select _id, title, des, img, info, cid from pole"
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        //traversing through all the records
        while(sqlite3_step(statement) == SQLITE_ROW){
            let _id = sqlite3_column_int(statement, 0)
            let title = String(cString: sqlite3_column_text(statement, 1))
            let des = String(cString: sqlite3_column_text(statement, 2))
            let img = String(cString: sqlite3_column_text(statement, 3))
            let info = String(cString: sqlite3_column_text(statement, 4))
            let cid = sqlite3_column_int(statement, 5)
            
            
            //adding values to list
            poleList.append(Pole(_id: Int(_id), title: String(describing: title), des: String(describing: des), img: String(describing: img), info:String(describing: info), cid: Int(cid)))
            print(personList.isEmpty)
        }
        
        /*//PRINTING DATA TO CONSOLE
         while sqlite3_step(statement) == SQLITE_ROW {
         
         let _id = sqlite3_column_int64(statement, 0)
         print("_id = \(_id); ", terminator: "")
         
         if let cString = sqlite3_column_text(statement, 1) {
         let title = String(cString: cString)
         print("title = \(title)")
         } else {
         print("title not found")
         }
         
         if let cString = sqlite3_column_text(statement, 2) {
         let des = String(cString: cString)
         print("des = \(des)")
         } else {
         print("des not found")
         }
         
         
         if let cString = sqlite3_column_text(statement, 3) {
         let img = String(cString: cString)
         print("img = \(img)")
         } else {
         print("img not found")
         }
         
         if let cString = sqlite3_column_text(statement, 2) {
         let info = String(cString: cString)
         print("info = \(info)")
         } else {
         print("info not found")
         }
         
         let cid = sqlite3_column_int64(statement, 4)
         print("cid = \(cid); ", terminator: "\n")
         
         }*/
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        
        print("**********recoverPersonData()*************")
        closeDatabase()
    }
    
    
    
    
    //-----------------------End--------SQLite--------------------------
    
}

// helper function to generate data model
func generate2DArrayofColor(withRows: Int, itemInEachRow: Int) -> [[UIColor]] {
    let numberOfRows = withRows
    let numberOfItemsInEachRow = itemInEachRow
    var color2DArray = [[UIColor]]()
    
    for row in 1...numberOfRows {
        var singleArray = [UIColor]()
        for item in 1...numberOfItemsInEachRow {
            if ((row + item) % 2) == 0 {
                singleArray.append(UIColor.cyan)
            }
            else {
                singleArray.append(UIColor.blue)
            }
        }
        color2DArray.append(singleArray)
    }
    return color2DArray
}

//////-------------------------------------------------------------------------------/////


//    func readValues(){
//
//        //first empty the list of canditas
//        catList.removeAll()
//
//        //this is our select query
//        let queryString = "SELECT * FROM cat"
//        print(queryString)
//        //statement pointer
//        var stmt:OpaquePointer?
//
//        //preparing the query
//        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
//            let errmsg = String(cString: sqlite3_errmsg(db)!)
//            print("error preparing insert: \(errmsg)")
//            return
//        }
//
//        //traversing through all the records
//        while(sqlite3_step(stmt) == SQLITE_ROW){
//            let _id = sqlite3_column_int(stmt, 0)
//            let name = String(cString: sqlite3_column_text(stmt, 1))
//            let iurl = String(cString: sqlite3_column_text(stmt, 2))
//            let pid = sqlite3_column_int(stmt, 3)
//
//            //adding values to list
//            catList.append(Cat(_id: Int(_id), name: String(describing: name), iurl: String(describing: iurl), pid: Int(pid)))
//            print(catList.isEmpty)
//        }
//
////        reloadData()
//
//    }



////----------------------Gatting-Data-from-Surbar--------------------
//
//
//
//
////    struct WebsiteDescription: Decodable {
////        let name: String
////        let description: String
////        let courses: [Course]
////    }
//
////    struct Course: Decodable {
////        let id: String?
////        let name: String?
////        let link: String?
////        let imageUrl: String?
////
////        //    init(json: [String: Any]) {
////        //        id = json["id"] as? Int ?? -1
////        //        name = json["name"] as? String ?? ""
////        //        link = json["link"] as? String ?? ""
////        //        imageUrl = json["imageUrl"] as? String ?? ""
////        //    }
////    }
//
//
//
//
//
//class ViewController: UIViewController {
//
//
//
//    //var catList = [Cat]()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        //Provide url link in string form
//        //let jsonUrlString = "https://api.letsbuildthatapp.com/jsondecodable/course"
//        //let jsonUrlString = "https://api.letsbuildthatapp.com/jsondecodable/courses"
//        //let jsonUrlString = "https://api.letsbuildthatapp.com/jsondecodable/website_description"
//        //let jsonUrlString = "https://api.letsbuildthatapp.com/jsondecodable/courses_missing_fields"
//        let jsonUrlString = "https://allnp.net/allpoll/getCat.php"
//
//
//        //Convert the string url into url form (object)
//        guard let url = URL(string: jsonUrlString) else { return }
//
//        URLSession.shared.dataTask(with: url) { (data, response, err) in
//            //perhaps check err
//            //also perhaps check response status 200 OK
//
//            guard let data = data else { return }
//
//            /*
//             //Give the data in string form
//             let dataAsString = String(data: data, encoding: .utf8)
//             print(dataAsString ?? "")
//             */
//
//
//            ///*
//            //Give the data in serilised form
//            Alamofire.request(jsonUrlString).responseJSON { response in
//                if response.result.isSuccess{
//                    print("Sucess! Got the Dta")
//
//                    self.dataIntoJason = JSON(response.result.value!)
//
//                    print(self.dataIntoJason)
//
//                    self.updateCatData(json: self.dataIntoJason) //TO UPDATE DATA
//                }
//                else{
//                    print("Error \(response.result.error)")
//                }
//            }//*/
//
//            //let stringIntoJson : JSON = JSON(dataAsString)
//            //print(dataAsString!)
//
//            //var json = JSON(stringLiteral: dataAsString!)
//            //var json = JSON.init(parseString:dataAsString)
//            //print(json)
//
//            do {
//
//                //JSON Parsing
//                /*let websiteDescription = try JSONDecoder().decode(WebsiteDescription.self, from: data)
//                 print(websiteDescription.name, websiteDescription.description, websiteDescription.courses )*/
//
//
//                //JSON Parsing
//                /*let courses = try JSONDecoder().decode(
//                 [Course].self, from: data)
//                 //print(courses.name!)
//                 print(courses)*/
//
//
//                //JSON Parsing
//                /*let course = try JSONDecoder().decode(
//                 Course.self, from: data)
//                 print(course.name!)
//                 print(course)*/
//
//
//                //JSON Parsing
//                ///*
//                self.cats = try JSONDecoder().decode([Cat].self, from: data)
//                //print(cats)
//                //*/
//
//
//                //Swift 2/3/ObjC
//                /*guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
//                 let course = Course(json: json)
//                 print(course.name)*/
//
//                /*//JASON SERIALIZATION DATA Swift 2/3/ObjC
//                 let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
//                 print(json)*/
//
//            } catch let jsonErr {
//                print("Error serializing json:", jsonErr)
//            }
//            }.resume()
//
//        //        //let dic = ["2": "B", "1": "A", "3": "C"]
//        //        let encoder = JSONEncoder()
//        //        if let jsonData = try? encoder.encode(cats) {
//        //            if let jsonString = String(data: jsonData, encoding: .utf8) {
//        //                print(jsonString)
//        //            }
//        //        }
//
//
//
//        //        let myCourse = Course(id: 1, name: "my course", link: "some link", imageUrl: "some image url")
//        //        print(myCourse)
//    }
//
//    func updateCatData(json: JSON){
//
//        for i in 0..<cats!.count{
//            candidate._id = json[i]["_id"].intValue
//            candidate.name = json[i]["name"].stringValue
//            candidate.img = json[i]["img"].stringValue
//            candidate.pid = json[i]["pid"].intValue
//
//            print(candidate._id, "\t"+candidate.name, "\t"+candidate.img, "\t", candidate.pid)
//            print("---------------------------------------")
//            //        print(candidate.name)
//            //        print(candidate.img)
//            //        print(candidate.pid)
//        }
//    }
//
//}
//----------------------Gatting-Data-from---------------------------














