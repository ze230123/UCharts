//
//  CollegeRankLineChart.swift
//  UCharts
//
//  Created by youzy on 2023/10/20.
//

import UIKit

class CollegeRankLineChart: UIView {
    private let maskLayer = CAShapeLayer()

    private let drawView = DrawView()

    var sourceView: UIView?
    var sourceRect: CGRect = .zero

    var dataSet: DataSet? {
        get {
            return drawView.dataSet
        }
        set {
            drawView.dataSet = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let arrowRect = sourceView?.convert(sourceRect, to: self) else {
            return
        }

        let centerX = arrowRect.maxX - (arrowRect.width / 2)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: centerX, y: 0))
        path.addLine(to: CGPoint(x: centerX - 8, y: 10))
        path.addLine(to: CGPoint(x: 8, y: 10))
        path.addArc(withCenter: CGPoint(x: 8, y: 18), radius: 8, startAngle: .pi * 3 / 2, endAngle: .pi, clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: rect.height - 8))
        path.addArc(withCenter: CGPoint(x: 8, y: rect.height - 8), radius: 8, startAngle: .pi, endAngle: .pi / 2, clockwise: false)
        path.addLine(to: CGPoint(x: rect.width - 8, y: rect.height))
        path.addArc(withCenter: CGPoint(x: rect.width - 8, y: rect.height - 8), radius: 8, startAngle: .pi / 2, endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x: rect.width, y: 18))
        path.addArc(withCenter: CGPoint(x: rect.width - 8, y: 18), radius: 8, startAngle: 0, endAngle: .pi * 3 / 2, clockwise: false)
        path.addLine(to: CGPoint(x: centerX + 8, y: 10))
        maskLayer.path = path.cgPath

        drawView.frame = CGRect(x: 0, y: 10, width: rect.width, height: rect.height - 10)
    }
}

extension CollegeRankLineChart {
    func prepare() {
        maskLayer.fillColor = UIColor.white.cgColor
        maskLayer.shadowColor = UIColor(white: 0, alpha: 0.05).cgColor
        maskLayer.shadowOffset = .zero
        maskLayer.shadowOpacity = 1
        maskLayer.shadowRadius = 5
        layer.insertSublayer(maskLayer, at: 0)

        drawView.backgroundColor = .clear
        addSubview(drawView)
    }
}

extension CollegeRankLineChart {
    struct DataSet {
        let max: Int
        let values: [Value]

        struct Value {
            let value: Int
            let year: Int
        }
    }

    private class DrawView: UIView {
        var dataSet: DataSet? {
            didSet {
                setNeedsDisplay()
            }
        }

        private let lineLayer = CAShapeLayer()
        private let dotLayer = CAShapeLayer()
        private let gradientLayer = CAGradientLayer()

        override init(frame: CGRect) {
            super.init(frame: frame)
            gradientLayer.colors = [UIColor(hex: 0xFF7D00, alpha: 0.22).cgColor, UIColor(hex: 0xFF7D00, alpha: 0.03).cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
            gradientLayer.locations = [0, 1]
            layer.addSublayer(gradientLayer)

            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.strokeColor = UIColor(hex: 0xFF7D00).cgColor
            lineLayer.lineWidth = 2

            layer.addSublayer(lineLayer)
            dotLayer.fillColor = UIColor.white.cgColor
            dotLayer.strokeColor = UIColor(hex: 0xFF7D00).cgColor
            dotLayer.lineWidth = 2
            layer.addSublayer(dotLayer)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func draw(_ rect: CGRect) {
            // 获取绘图上下文
            guard let context = UIGraphicsGetCurrentContext() else {
                return
            }

            guard let dataSet = dataSet else {
                return
            }

            debugPrint("绘制图表")
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let textFont = UIFont.systemFont(ofSize: 10)
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: textFont,
                .foregroundColor: UIColor(hex: 0x999999),
                .paragraphStyle: paragraphStyle
            ]

            let valueFont = UIFont.systemFont(ofSize: 12)
            let valueAttributes: [NSAttributedString.Key: Any] = [
                .font: valueFont,
                .foregroundColor: UIColor(hex: 0x333333),
                .paragraphStyle: paragraphStyle
            ]

            let xAxisFrame = CGRect(x: 0, y: rect.height - 30, width: rect.width, height: 30)
            let textFrame = CGRect(x: 0, y: 0, width: rect.width, height: textFont.lineHeight)
            let contentFrame = CGRect(x: xAxisFrame.minX, y: textFrame.maxY, width: xAxisFrame.width, height: xAxisFrame.minY - textFrame.maxY)

            let maxValue = dataSet.max

            let scale = contentFrame.height / CGFloat(maxValue)

            let valueWidth = contentFrame.width / CGFloat(dataSet.values.count)

            var points: [CGPoint] = []

            let dotPath = UIBezierPath()

            dataSet.values.enumerated().forEach { item in
                // X轴名称绘制
                let xAxisName = "\(item.element.year)"
                let x = valueWidth * CGFloat(item.offset)
                let xAxisNameFrame = CGRect(x: xAxisFrame.minX + x, y: xAxisFrame.minY + 8, width: valueWidth, height: textFont.lineHeight)
                (xAxisName as NSString).draw(in: xAxisNameFrame, withAttributes: textAttributes)

                let gValue = maxValue - item.element.value
                let gHeight = scale * CGFloat(gValue)
                let gMinY = contentFrame.maxY - gHeight

                let dotFrame = CGRect(x: xAxisNameFrame.midX - 3, y: gMinY - 3, width: 6, height: 6)
                let path = UIBezierPath(roundedRect: dotFrame, cornerRadius: 6)

                dotPath.append(path)

                points.append(CGPoint(x: dotFrame.midX, y: dotFrame.midY))

                let value = "\(item.element.value)"
                let valueFrame = CGRect(x: xAxisFrame.minX + x, y: dotFrame.minY - 2 - valueFont.lineHeight, width: valueWidth, height: valueFont.lineHeight)
                (value as NSString).draw(in: valueFrame, withAttributes: valueAttributes)
            }

            // 绘制X轴
            context.move(to: CGPoint(x: xAxisFrame.minX + 20, y: xAxisFrame.minY))
            context.addLine(to: CGPoint(x: xAxisFrame.maxX - 20, y: xAxisFrame.minY))
            context.setStrokeColor(UIColor(hex: 0xF6F6F6).cgColor)
            context.strokePath()

            dotLayer.path = dotPath.cgPath

            let linePath = DrawUtils.linePath(of: points)
            lineLayer.path = linePath.cgPath

            let maskPath = linePath
            maskPath.addLine(to: CGPoint(x: points.last?.x ?? 0, y: contentFrame.maxY))
            maskPath.addLine(to: CGPoint(x: points.first?.x ?? 0, y: contentFrame.maxY))

            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            maskLayer.strokeColor = UIColor.clear.cgColor

            gradientLayer.frame = rect
            gradientLayer.mask = maskLayer
        }
    }
}

struct DrawUtils {
    static func linePath(of points: [CGPoint]) -> UIBezierPath {
        func getControlPoint(_ x0: CGFloat, y0: CGFloat, x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, x3: CGFloat, y3: CGFloat, path: UIBezierPath) {
            let smoothValue: CGFloat = 0.6
            var ctrl1X: CGFloat = 0
            var ctrl1Y: CGFloat = 0
            var ctrl2X: CGFloat = 0
            var ctrl2Y: CGFloat = 0
            let xc1: CGFloat = (x0 + x1) / 2.0
            let yc1: CGFloat = (y0 + y1) / 2.0
            let xc2: CGFloat = (x1 + x2) / 2.0
            let yc2: CGFloat = (y1 + y2) / 2.0
            let xc3: CGFloat = (x2 + x3) / 2.0
            let yc3: CGFloat = (y2 + y3) / 2.0
            let len1: CGFloat = sqrt((x1-x0) * (x1-x0) + (y1-y0) * (y1-y0))
            let len2: CGFloat = sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1))
            let len3: CGFloat = sqrt((x3-x2) * (x3-x2) + (y3-y2) * (y3-y2))
            let k1: CGFloat = len1 / (len1 + len2)
            let k2: CGFloat = len2 / (len2 + len3)
            let xm1: CGFloat = xc1 + (xc2 - xc1) * k1
            let ym1: CGFloat = yc1 + (yc2 - yc1) * k1
            let xm2: CGFloat = xc2 + (xc3 - xc2) * k2
            let ym2: CGFloat = yc2 + (yc3 - yc2) * k2
            ctrl1X = xm1 + (xc2 - xm1) * smoothValue + x1 - xm1
            ctrl1Y = ym1 + (yc2 - ym1) * smoothValue + y1 - ym1
            ctrl2X = xm2 + (xc2 - xm2) * smoothValue + x2 - xm2
            ctrl2Y = ym2 + (yc2 - ym2) * smoothValue + y2 - ym2
            path.addCurve(to: CGPoint(x: x2, y: y2), controlPoint1: CGPoint(x: ctrl1X, y: ctrl1Y), controlPoint2: CGPoint(x: ctrl2X, y: ctrl2Y))
        }

        var newPoints = points
        newPoints.insert(points.first ?? .zero, at: 0)
        newPoints.append(points.last ?? .zero)

        let path = UIBezierPath()
        for idx in 0..<newPoints.count - 3 {
            let p1 = newPoints[idx]
            let p2 = newPoints[idx + 1]
            let p3 = newPoints[idx + 2]
            let p4 = newPoints[idx + 3]
            if idx == 0 {
                path.move(to: p2)
            }
            getControlPoint(p1.x, y0: p1.y, x1: p2.x, y1: p2.y, x2: p3.x, y2: p3.y, x3: p4.x, y3: p4.y, path: path)
        }
        return path
    }
}
