//
//  ViewController.swift
//  BitcoinTracker
//
//  Created by AmitArya on 9/3/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var btcPrice: UILabel!
    @IBOutlet weak var ethPrice: UILabel!
    @IBOutlet weak var usdPrice: UILabel!
    @IBOutlet weak var audPrice: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    let urlString = "https://api.coingecko.com/api/v3/exchange_rates"
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(refreshData), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if timer != nil{
            timer?.invalidate()
        }
    }

    
    @objc func refreshData()-> Void{
        fetchData()
    }
    
    func fetchData(){
        guard let url = URL(string: urlString) else { return }
        let defaultSession = URLSession(configuration: .default)
        let dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
            
            if(error != nil){
                print(error!)
                return
            }
            
            do{
                let json = try JSONDecoder().decode(Rates.self, from: data!)
                self?.setPrices(currency: json.rates)
            }
            catch{
                print(error)
                return
            }
        }
        dataTask.resume()
    }
    
    func setPrices(currency: Currency){
        
        DispatchQueue.main.async {
            self.btcPrice.text = self.formatString(currency.btc)
            self.ethPrice.text = self.formatString(currency.eth)
            self.usdPrice.text = self.formatString(currency.usd)
            self.audPrice.text = self.formatString(currency.aud)
            self.lastUpdatedLabel.text = self.formatDate(date: Date())
        }
    }
    
    func formatString(_ price: Price) -> String{
        return String(format: "%@ %.4f", price.unit, price.value)
    }
    
    func formatDate(date: Date)-> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM y HH:mm:ss"
        return formatter.string(from: date)
    }
    
    struct Rates: Codable{
        let rates: Currency
    }
    
    struct Currency: Codable{
        let btc: Price
        let eth: Price
        let usd: Price
        let aud: Price
    }
    
    struct Price: Codable{
        let name: String
        let unit: String
        let value: Float
        let type: String
    }


}

