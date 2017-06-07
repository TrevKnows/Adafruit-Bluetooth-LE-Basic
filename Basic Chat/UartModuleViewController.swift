//
//  UartModuleViewController.swift
//  Basic Chat
//
//  Created by Trevor Beaton on 12/4/16.
//  Copyright © 2016 Vanguard Logic LLC. All rights reserved.
//




    
import UIKit
import CoreBluetooth

class UartModuleViewController: UIViewController, CBPeripheralManagerDelegate, UITextViewDelegate, UITextFieldDelegate {
  
    //UI
    @IBOutlet weak var baseTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var switchUI: UISwitch!
    //Data
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral!
    private var blueFontDict:NSDictionary!
    private var consoleAsciiText:NSAttributedString? = NSAttributedString(string: "")
    var dataBuffer = NSMutableData()
    var transferChar: CBMutableCharacteristic?
    var sendingData = false
    var currentText = ""
    var dataToTransmit: Data?
    var sendDataIndex = 0
    let EOM = "End Of Message"
    var outgoingArray = [characteristicASCIIValue]
    let TxMaxCharacters = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"Back", style:.plain, target:nil, action:nil)
        self.baseTextView.delegate = self
        self.inputTextField.delegate = self
        //Base text view setup
        self.baseTextView.layer.borderWidth = 3.0
        self.baseTextView.layer.borderColor = UIColor.blue.cgColor
        self.baseTextView.layer.cornerRadius = 3.0
        //Input Text Field setup
        self.inputTextField.layer.borderWidth = 2.0
        self.inputTextField.layer.borderColor = UIColor.blue.cgColor
        self.inputTextField.layer.cornerRadius = 3.0
        //Create and start the peripheral manager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        //-Notification for updating the text view with incoming text
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil){
            notification in
           self.baseTextView.text = "\(characteristicASCIIValue)"
        }
    }
   
    override func viewDidAppear(_ animated: Bool) {
        self.baseTextView.text = ""
        dataBuffer = NSMutableData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        peripheralManager?.stopAdvertising()
        self.peripheralManager = nil
        super.viewDidDisappear(animated)
    }
    
    // MARK: Data Transfer Methods
    func updateTextView (){
        let appendString = ""
        let attributedStr = NSMutableAttributedString(string: (characteristicASCIIValue as String) + appendString)
        let textViewStr = "\(attributedStr)"
        baseTextView.text = "\(textViewStr)\n"
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil){
            notification in
            self.baseTextView.text = (((characteristicASCIIValue) as String) + appendString)
        }
    }
  
    /*
    COME BACK TO THIS
     
     func updateConsole(asciiText: NSAttributedString){
     consoleAsciiText = asciiText
     baseTextView.attributedText = consoleAsciiText
     }
   */
   @IBOutlet weak var toggleButton: UIButton!
    
    @IBAction func toggleOn(_ sender: Any) {
    writeCharacteristic(val: 1)
    }  
    
    @IBAction func toggleOff(_ sender: Any) {
    writeCharacteristic(val: 0)
    }

    @IBAction func clickSendAction(_ sender: AnyObject) {
        let text = inputTextField.text != nil ? inputTextField.text! : ""
    //  self.baseTextView.text = "Sent: \(newText)"
        var newText = text
        writeValue(data: newText)
        
        inputTextField.text = ""
        updateTextView()
       
        if inputTextField.text == "" {
            textArray.append(text)
        }
        
    }
    
    // Write functions
    func writeValue(data: String){
            let data = (data as NSString).data(using: String.Encoding.utf8.rawValue)
            if let blePeripheral = blePeripheral{
        
                if let txCharacteristic = txCharacteristic {
            
                    blePeripheral.writeValue(data!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }

    func writeCharacteristic(val: Int8){
        var val = val
        let ns = NSData(bytes: &val, length: MemoryLayout<Int8>.size)
        blePeripheral!.writeValue(ns as Data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    
    
    //MARK: UITextViewDelegate methods
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView === baseTextView {
            //tapping on consoleview dismisses keyboard
            inputTextField.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
      scrollView.setContentOffset(CGPoint(x:0, y:250), animated: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            return
        }
        print("Peripheral manager is running")
    }

    //Check when someone subscribe to our characteristic, start sending the data
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Device subscribe to characteristic")
    }
    
    //This on/off switch sends a value of 1 and 0 to the Arduino
    //This can be used as a switch or any thing you'd like
     @IBAction func switchAction(_ sender: Any) {
        if switchUI.isOn {
            print("On ")
            writeCharacteristic(val: 1)
        }
        else
        {
            print("Off")
            writeCharacteristic(val: 0)
            print(writeCharacteristic)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return(true)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("\(error)")
            return
        }
    }
}
