//
//  Tile.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/8/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class Tile: UIView {
    
    var number: Int = 0 {
        didSet {
            numberLabel?.text = String(number)
        }
    }
    var numberLabel: UILabel!
    
    var padding: CGFloat = 5.0
    
    var borderColor: UIColor = UIColor.blackColor() {
        didSet {
            self.layer.borderColor = borderColor.CGColor
        }
    }
    
    var views = [String: UIView]()
    var metrics = [String: CGFloat]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    // MARK:- Init Methods
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        self.layer.borderColor = borderColor.CGColor
        self.layer.borderWidth = 3.0
        
        numberLabel = UILabel()
        numberLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        numberLabel.numberOfLines = 1
        numberLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 40)
        numberLabel.minimumScaleFactor = 12.0 / numberLabel.font.pointSize
        numberLabel.adjustsFontSizeToFitWidth = true
        numberLabel.text = String(number)
        numberLabel.textAlignment = NSTextAlignment.Center
        
        numberLabel.setContentCompressionResistancePriority(900, forAxis: UILayoutConstraintAxis.Horizontal)
        numberLabel.setContentCompressionResistancePriority(900, forAxis: UILayoutConstraintAxis.Vertical)
        numberLabel.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
        numberLabel.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        
        views["numberLabel"] = numberLabel
        self.addSubview(numberLabel)
        
        metrics["padding"] = padding
        
        self.addConstraint(NSLayoutConstraint(item: numberLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: numberLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=padding)-[numberLabel]-(>=padding)-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=padding)-[numberLabel]-(>=padding)-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
    }
}
