//
//  CollegeRankChart.swift
//  UCharts
//
//  Created by youzy on 2023/10/19.
//

import UIKit
import UBase

protocol CollegeRankChartDelegate: AnyObject {
    /// 点击柱子通知
    /// - Parameters:
    ///   - chart: 柱状图
    ///   - layerFrame: 柱子的frame
    ///   - index: 柱子的下标，从0开始
    func chart(_ chart: CollegeRankChart, didSelect layerFrame: CGRect, at index: Int)
}

class CollegeRankChart: UIView {
    var dataSet: DataSet? {
        didSet {
            setNeedsDisplay()
        }
    }

    private var selectLayer: RankLayer? {
        didSet {
            oldValue?.isSelected = false
            selectLayer?.isSelected = true
            if let selectLayer = selectLayer, let index = layers.firstIndex(of: selectLayer) {
                delegate?.chart(self, didSelect: selectLayer.frame, at: index)
            }
        }
    }

    private var layers: [RankLayer] = []

    weak var delegate: CollegeRankChartDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }

    override func draw(_ rect: CGRect) {
        guard let dataSet = dataSet else {
            return
        }
        /// x轴区域
        let xAxisFrame = CGRect(x: 0, y: rect.height - 40, width: rect.width, height: 40)

        let contentWidth = rect.width / CGFloat(dataSet.values.count)

        let maxValue = dataSet.max

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let textFont = UIFont.systemFont(ofSize: 12)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: textFont,
            .foregroundColor: UIColor(hex: 0x333333),
            .paragraphStyle: paragraphStyle
        ]

        dataSet.values.enumerated().forEach { item in
            // X轴名称绘制
            let xAxisName = item.element.name
            let x = contentWidth * CGFloat(item.offset)
            let xAxisNameFrame = CGRect(x: x, y: xAxisFrame.minY + 8, width: contentWidth, height: textFont.lineHeight)
            (xAxisName as NSString).draw(in: xAxisNameFrame, withAttributes: textAttributes)
            // X轴年份绘制
            let xAxisYear = "\(item.element.year)"
            let xAxisYearFrame = CGRect(x: x, y: xAxisNameFrame.maxY + 2, width: contentWidth, height: textFont.lineHeight)
            (xAxisYear as NSString).draw(in: xAxisYearFrame, withAttributes: textAttributes)

            // 柱子绘制
            let radius = (contentWidth - 25) / 2
            let gX = contentWidth * CGFloat(item.offset) + radius
            let gFrame = CGRect(x: gX, y: 0, width: 25, height: xAxisFrame.minY)

            let gLayer = RankLayer(value: item.element.value, max: maxValue, frame: gFrame)
            gLayer.selectTextColor = UIColor(hex: 0xFF7D00)
            gLayer.textColor = UIColor(hex: 0x333333)
            gLayer.colors = [UIColor(hex: 0x7EA5FF).cgColor, UIColor(hex: 0xB9D9FF).cgColor]
            gLayer.selectColors = [UIColor(hex: 0xFF7D00).cgColor, UIColor(hex: 0xFFCB98).cgColor]
            layer.addSublayer(gLayer)
            layers.append(gLayer)
        }

        let lineX = layers.first?.frame.minX ?? 0
        let lineMaxX = layers.last?.frame.maxX ?? 0
        let lineFrame = CGRect(x: lineX, y: xAxisFrame.minY, width: lineMaxX - lineX, height: 1)
        let lineLayer = CALayer()
        lineLayer.backgroundColor = UIColor(hex: 0xEBEBEB).cgColor
        lineLayer.frame = lineFrame
        layer.addSublayer(lineLayer)

        selectLayer = layers.first
    }
}

extension CollegeRankChart {
    func prepare() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }

    @objc func tapAction(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self)
        selectLayer = layers.first(where: { $0.frame.contains(point) })
    }
}

extension CollegeRankChart: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: self)
        return layers.contains(where: { $0.frame.contains(point) })
    }
}

extension CollegeRankChart {
    struct DataSet {
        /// 最大值
        let max: Int
        let values: [Value]

        struct Value {
            let name: String
            let year: Int
            let value: Int
        }
    }

    private class RankLayer: CALayer {
        /// 文字图层
        let textLayer = CATextLayer()
        /// 柱子渐变图层
        let gLayer = CAGradientLayer()

        /// 文字颜色
        var textColor: UIColor?
        /// 柱子渐变颜色数组
        var colors: [CGColor] = []

        /// 文字选中颜色
        var selectTextColor: UIColor?
        /// 柱子选中渐变颜色
        var selectColors: [CGColor] = []

        /// 文字高度限制
        private let textHeight: CGFloat = 20
        /// 字体高度
        private let textFont = UIFont.medium(ofSize: 16)

        /// 是否选中
        var isSelected: Bool = false {
            didSet {
                reload()
            }
        }

        /// 数值
        let value: Int
        /// 最大值
        let max: Int

        init(value: Int, max: Int, frame: CGRect) {
            self.value = value
            self.max = max
            super.init()
            self.frame = frame

            textLayer.font = CGFont(textFont.fontName as CFString)
            textLayer.fontSize = textFont.pointSize
            textLayer.alignmentMode = .center
            textLayer.string = "\(value)"
            addSublayer(textLayer)

            gLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gLayer.endPoint = CGPoint(x: 0.5, y: 1)
            gLayer.locations = [0, 1]
            addSublayer(gLayer)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSublayers() {
            let scale = (bounds.height - textHeight) / CGFloat(max)
            let gValue = max - value
            let gHeight = scale * CGFloat(gValue)
            let gMinY = bounds.height - gHeight

            gLayer.frame = CGRect(x: 0, y: gMinY, width: bounds.width, height: gHeight)
            textLayer.frame = CGRect(x: 0, y: gLayer.frame.minY - 2 - textFont.lineHeight, width: bounds.width, height: textFont.lineHeight)

            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(roundedRect: gLayer.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 4, height: 4)).cgPath
            gLayer.mask = maskLayer

            reload()
        }

        func reload() {
            textLayer.foregroundColor = isSelected ? selectTextColor?.cgColor : textColor?.cgColor
            gLayer.colors = isSelected ? selectColors : colors
        }
    }
}
