//
//  TextPickerView.swift
//  MemeMe
//
//  Created by Corey Baines on 14/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import UIKit

class TextPickerView: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var fontPicker: UIPickerView!
    
    var fontAttributer: FontAttribute = FontAttribute()
    var pickerData = [String]()
    let fontFamily = UIFont.familyNames()
    
    //# -- MARK: Lifecycle Methods:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Fill array with font names */
        for family in fontFamily {
            pickerData.appendContentsOf((UIFont.fontNamesForFamilyName(family)))
        }
        
        /* Set picker data source and delegate */
        fontPicker.dataSource = self
        fontPicker.delegate = self
        
        /* Set default row selection of picker */
        setFontAttributeDefaults(fontAttributer.fontSize, fontName: fontAttributer.fontName, fontColor: fontAttributer.fontColor)
        setValuesOfUIElementsForFontAttributes()
    }
    
    /* Set view as first responder to handle shake notifications and avoid any popover trouble */
    override func viewDidAppear(animated: Bool) {
        //becomeFirstResponder()
    }
    
    //# -- MARK: Alert and reset the UI if user selects reset:
    func alertForReset() {
        let ac = UIAlertController(title: "Reset?", message: "Are you sure you want to reset the font size and type?", preferredStyle: .Alert)
        let resetAction = UIAlertAction(title: "Reset", style: .Default, handler: { Void in
            /* Reset to default values and update the Meme's font */
            self.setFontAttributeDefaults(40.0, fontName: "HelveticaNeue-CondensedBlack", fontColor: UIColor.whiteColor())
            self.setValuesOfUIElementsForFontAttributes()
            self.updateMemeFont()
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        /* Alert user before reset */
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        ac.addAction(resetAction)
        ac.addAction(cancelAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    /* Set default font attibutes */
    func setFontAttributeDefaults(fontSize: CGFloat = 40.0, fontName: String = "HelveticaNeue-CondensedBlack", fontColor: UIColor = UIColor.whiteColor()){
        fontAttributer.fontSize = fontSize
        fontAttributer.fontName = fontName
        fontAttributer.fontColor = fontColor
    }
    
    /* Set UI Elements based on stored font attributes */
    func setValuesOfUIElementsForFontAttributes() {
        /* Set font slider's value to the font size */
        fontSizeSlider.value = Float(fontAttributer.fontSize)
        
        /* Set picker to the font that is stored */
        let index = pickerData.indexOf(fontAttributer.fontName)
        if let index = index {
            fontPicker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    /* Update the MemeEditor font and reconfigure the view */
    func updateMemeFont(){
        let parent = presentingViewController as! EditorVC
        parent.fontAttributer.fontSize = fontAttributer.fontSize
        parent.fontAttributer.fontName = fontAttributer.fontName
        parent.setuplabels([parent.topLabel, parent.bottomLabel])
    }
    
    /* Respond to changes in the font slider */
    @IBAction func didChangeSlider(sender: UISlider) {
        
        let fontSize = CGFloat(fontSizeSlider.value)
        fontAttributer.fontSize = fontSize
        
        updateMemeFont()
    }
    
    //# -- MARK: Picker Delegate and Data Source methods:
    
    /* Picker data source methods */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    /* Picker Delegate Methods */
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        fontAttributer.fontName = pickerData[row]
        updateMemeFont()
    }
    
}