//
//  FirstViewController.swift
//  TravelRepublic
//
//  Created by Guillaume Manzano on 07/02/2017.
//  Copyright © 2017 Guillaume Manzano. All rights reserved.
//

import UIKit
import Alamofire

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    private var refreshControl: UIRefreshControl!
    private var isRefreshing: Bool = false
    private var dealsArray = [DealModel]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dealsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dealModel = self.dealsArray[indexPath.row]
        
        let cell:DealsTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "DealsTViewCell") as! DealsTableViewCell
        cell.backgroundImageView.image = ImageCacheHelper.GetImageById(id: (dealModel.id)!)
        cell.country?.text = dealModel.title
        cell.count?.text = String(describing: (dealModel.country)!)
        cell.price?.text = String(describing: (dealModel.price)!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    private func GetParameter() -> Parameters
    {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'00:00:00Z"
        
        let parameters: Parameters = [
            "CheckInDate": formatter.string(from: currentDateTime), // get current date
            "Flexibility": 3,
            "Duration":7,
            "Adults":2,
            "DomainId":1,
            "CultureCode":"en-gb",
            "CurrencyCode":"GBP",
            "OriginAirports":["LHR","LCY","LGW","LTN","STN","SEN"],
            "FieldFlags":8143571,
            "IncludeAggregates":true
        ]
        return parameters
    }
    
    private func VerifiyTypes(JSON: Any?) -> Bool
    {
        return true
    }
    
    private func GetData()
    {
        let parameters = GetParameter()
        
        Alamofire.request("https://www.travelrepublic.co.uk/api/hotels/deals/search?fields=Aggregates.HotelsByChildDestination", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if let JSON = response.result.value {
                if JSON is NSDictionary {
                    var tmpDeals = [DealModel]()
                    let Aggregates = (JSON as! NSDictionary).value(forKey: "Aggregates")
                    if Aggregates is NSDictionary {
                        let dealsNotSorted = (Aggregates as! NSDictionary).value(forKey: "HotelsByChildDestination")
                        if dealsNotSorted is NSDictionary {
                            let deals = (dealsNotSorted as! NSDictionary).sorted(by: { (($0.value as! NSDictionary).value(forKey: "Position") as! Int) < (($1.value as! NSDictionary).value(forKey: "Position") as! Int) })
                            for deal in deals
                            {
                                let tokens = (deal.key as! String).components(separatedBy: "|")
                                let imageUrl = "https://d2f0rb8pddf3ug.cloudfront.net/api2/destination/images/getfromobject?id=\(tokens[1])&type=\(tokens[0])&useDialsImages=true&width=375&height=150"
                                if ImageCacheHelper.GetImageById(id: imageUrl) == nil
                                {
                                    if let url = NSURL(string: imageUrl) {
                                        if let data = NSData(contentsOf: url as URL) {
                                            ImageCacheHelper.SaveImage(image: UIImage(data: data as Data)!, id: tokens[1])
                                        }
                                    }
                                }
                                let title = (deal.value as! NSDictionary).value(forKey: "Title") as! String
                                let count = (deal.value as! NSDictionary).value(forKey: "Count") as! Int
                                let price = (deal.value as! NSDictionary).value(forKey: "MinPrice") as! Int
                                tmpDeals.append(DealModel(id: tokens[1], title: title, type: tokens[0], country: count, price: price))
                            }
                            self.dealsArray = tmpDeals
                            self.ShowDatas(reload: true)
                        }
                    }
                }
            }
            else {
                self.ShowError()
            }
        }
        
    }
    
    private func ShowError()
    {
        let alert = UIAlertController(title: "Error", message: "Network error, please verify your connection", preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
        self.ShowDatas(reload: false)
    }
    
    private func StopRefresh()
    {
        if self.isRefreshing == true
        {
            self.isRefreshing = false
            refreshControl.endRefreshing()
        }
    }
    
    func Refresh(sender:AnyObject) {
        isRefreshing = true
        GetData()
    }
    
    private func ShowDatas(reload: Bool)
    {
        self.tableView.isHidden = false
        self.indicator.isHidden = true
        self.indicator.stopAnimating()
        self.StopRefresh()
        if reload == true {
            self.tableView.reloadData()
        }
    }
    
    private func StartIndicator()
    {
        tableView.isHidden = true
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StartIndicator()
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.Refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        GetData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

