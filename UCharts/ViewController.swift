//
//  ViewController.swift
//  UCharts
//
//  Created by youzy on 2023/10/19.
//

import UIKit

struct CollegeRank {
    let name: String
    let year: Int
    let value: Int

    let historys: [History]

    struct History {
        let year: Int
        let value: Int
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var chart: CollegeRankChart!
    @IBOutlet weak var lineChart: CollegeRankLineChart!

    let items: [CollegeRank] = [
        CollegeRank(name: "易度排名", year: 2023, value: 1, historys: [
            CollegeRank.History(year: 2023, value: 1),
            CollegeRank.History(year: 2022, value: 6),
            CollegeRank.History(year: 2021, value: 4),
            CollegeRank.History(year: 2020, value: 8),
            CollegeRank.History(year: 2019, value: 3),
        ]),
        CollegeRank(name: "校友会", year: 2023, value: 4, historys: [
            CollegeRank.History(year: 2023, value: 4),
            CollegeRank.History(year: 2022, value: 6),
            CollegeRank.History(year: 2021, value: 4),
            CollegeRank.History(year: 2020, value: 8),
            CollegeRank.History(year: 2019, value: 3),
        ]),
        CollegeRank(name: "软科", year: 2023, value: 6, historys: [
            CollegeRank.History(year: 2023, value: 6),
            CollegeRank.History(year: 2022, value: 6),
            CollegeRank.History(year: 2021, value: 4),
            CollegeRank.History(year: 2020, value: 8),
            CollegeRank.History(year: 2019, value: 3),
        ]),
        CollegeRank(name: "QS", year: 2023, value: 2, historys: [
            CollegeRank.History(year: 2023, value: 2),
            CollegeRank.History(year: 2022, value: 6),
            CollegeRank.History(year: 2021, value: 4),
            CollegeRank.History(year: 2020, value: 8),
            CollegeRank.History(year: 2019, value: 3),
        ]),
        CollegeRank(name: "USNews", year: 2023, value: 5, historys: [
            CollegeRank.History(year: 2023, value: 5),
            CollegeRank.History(year: 2022, value: 6),
            CollegeRank.History(year: 2021, value: 4),
            CollegeRank.History(year: 2020, value: 8),
            CollegeRank.History(year: 2019, value: 3),
        ]),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        let values: [CollegeRankChart.DataSet.Value] = items.map { CollegeRankChart.DataSet.Value(name: $0.name, year: $0.year, value: $0.value) }
        let max = values.map { $0.value }.max().map { $0 + 1 } ?? 1
        chart.dataSet = CollegeRankChart.DataSet(max: max, values: values)
        chart.delegate = self
        chart.layer.borderColor = UIColor.lightGray.cgColor
        chart.layer.borderWidth = 0.5
    }
}

extension ViewController: CollegeRankChartDelegate {
    func chart(_ chart: CollegeRankChart, didSelect layerFrame: CGRect, at index: Int) {
        lineChart.sourceView = chart
        lineChart.sourceRect = layerFrame

        let values: [CollegeRankLineChart.DataSet.Value] = items[index].historys.map { CollegeRankLineChart.DataSet.Value(value: $0.value, year: $0.year) }
        let max = values.map { $0.value }.max().map { $0 + 1 } ?? 1
        lineChart.dataSet = CollegeRankLineChart.DataSet(max: max, values: values)

        lineChart.setNeedsDisplay()
    }
}
