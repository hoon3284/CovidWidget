//
//  ViewController.swift
//  CovidWidget
//
//  Created by wickedRun on 2021/12/12.
//

import UIKit
import WidgetKit

class ViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    var covidInfos: [CovidInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let today = CovidInfoParser.shared.queryDateFormatter.string(from: Date()-1800)
        var url = URLComponents(string: "http://openapi.data.go.kr/openapi/service/rest/Covid19/getCovid19SidoInfStateJson")!
        url.percentEncodedQueryItems = [
            "serviceKey": Bundle.main.apiKey,
            "pageNo": "1",
            "numOfRows": "10",
            "startCreateDt": today,
            "endCreateDt": today
        ].map { URLQueryItem(name: $0, value: $1) }
        
        let parser = XMLParser(contentsOf: url.url!)
        parser?.delegate = CovidInfoParser.shared
        parser?.parse()
        
        covidInfos = CovidInfoParser.shared.items
        let total = covidInfos.first { $0.gubunEn == "Total" }!
        let data = try? JSONEncoder().encode(total)
        UserDefaults.shared.setValue(data, forKey: "DailyTotal")
        titleLabel.text! += "\n" + CovidInfo.dateFormatter.string(from: total.standardDay)
        for info in covidInfos {
            textView.text += info.description + "\n"
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "CovidWidget")
    }
    
}
