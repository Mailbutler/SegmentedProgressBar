//
//  SegmentedProgressBar.swift
//  Mailbutler
//
//  Created by Fabian Jäger on 10.06.17.
//  Copyright © 2017 Mailbutler. All rights reserved.
//

import Cocoa

struct ProgressSegment {
    let value: CGFloat
    let valueString: NSString?
    let label: NSString?
    let color: NSColor?
}

class SegmentedProgressBar: NSView {

    @IBInspectable var maxValue: CGFloat = CGFloat.greatestFiniteMagnitude {
        didSet { needsDisplay = true }
    }

    @IBInspectable var barHeight: CGFloat = 22.0 {
        didSet { needsDisplay = true }
    }

    @IBInspectable var drawLegend: Bool = true {
        didSet { needsDisplay = true }
    }

    var segments: [ProgressSegment]? {
        didSet{ needsDisplay = true }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let segments = segments else {
            return
        }

        // draw segmented bar first
        let segmentedBarRect = NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y+dirtyRect.size.height-self.barHeight, dirtyRect.size.width, self.barHeight)

        // set overall clipping of our view
        let cornerRadius = self.barHeight/4.0;
        let clippingPath = NSBezierPath(roundedRect: segmentedBarRect, xRadius: cornerRadius, yRadius: cornerRadius)
        clippingPath.addClip()

        // fill with white background
        NSColor.white.set()
        clippingPath.fill()

        var realMaxValue = self.maxValue
        if(maxValue == CGFloat.greatestFiniteMagnitude)
        {
            realMaxValue = 0.0;
            // get max value as sum of all segments
            for segment in segments {
                realMaxValue += segment.value
            }
        }

        // draw each segment individually
        var segStartX = dirtyRect.origin.x
        var i: Int = 0
        for segment in segments {
            guard segment.value > 0 else {
                continue
            }

            let segmentColor = segment.color ?? NSColor.black

            let width = max((segment.value/realMaxValue)*dirtyRect.size.width, 2.0)

            let segmentRect = NSMakeRect(segStartX, segmentedBarRect.origin.y, width, segmentedBarRect.size.height)

            segmentColor.set()
            segmentRect.fill()

            segStartX += width
            i += 1
        }

        // draw bounding line
        clippingPath.lineWidth = 1.0
        NSColor.lightGray.set()
        clippingPath.stroke()

        let spacing: CGFloat = 4.0

        // draw legend next
        NSBezierPath(rect: dirtyRect).setClip()
        let legendRectSize: CGFloat = 10.0

        var legendItemX = spacing + dirtyRect.origin.x;
        let legendTopY  = dirtyRect.origin.y+dirtyRect.size.height-self.barHeight-spacing*3.0;
        i = 0;
        for segment in segments {
            guard segment.value > 0 else {
                continue
            }
            guard let segmentLabel = segment.label else {
                continue
            }

            let segmentColor = segment.color ?? NSColor.black
            let segmentValue = segment.valueString ?? "\((segment.value/realMaxValue*100).rounded())%" as NSString

            // draw legend color rect
            let legendRect = NSMakeRect(legendItemX, legendTopY-legendRectSize, legendRectSize, legendRectSize)
            let legendPath = NSBezierPath(roundedRect: legendRect, xRadius: legendRectSize/4.0, yRadius: legendRectSize/4.0)

            segmentColor.set()
            legendPath.fill()
            NSColor.lightGray.set()
            legendPath.lineWidth = 0.5
            legendPath.stroke()

            // draw label next to rect
            let legendItemLabelX = legendRect.origin.x + legendRect.size.width + spacing*1.5

            let labelFont = NSFont.boldSystemFont(ofSize: 10.0)
            let labelAttributes = [NSAttributedStringKey.font:labelFont]
            let labelBounds = segmentLabel.boundingRect(with: dirtyRect.size, options: [], attributes: labelAttributes)

            let legendItemLabelRect = NSMakeRect(legendItemLabelX, legendRect.origin.y-2.0, labelBounds.size.width, labelBounds.size.height)
            segmentLabel.draw(in: legendItemLabelRect, withAttributes: labelAttributes)

            // draw value of legend item
            let valueFont = NSFont.systemFont(ofSize: 10.0)
            let valueAttributes = [NSAttributedStringKey.font:valueFont]

            let valueBounds = segmentValue.boundingRect(with: dirtyRect.size, options: [], attributes: valueAttributes)

            let legendItemValueRect = NSMakeRect(legendItemLabelX, legendItemLabelRect.origin.y-spacing*0.5-valueBounds.size.height, valueBounds.size.width, valueBounds.size.height)
            segmentValue.draw(in: legendItemValueRect, withAttributes: valueAttributes)

            // prepare for next item
            legendItemX += legendRect.size.width + spacing + max(valueBounds.size.width, labelBounds.size.width) + spacing*4.0
            i += 1
        }
    }
}
