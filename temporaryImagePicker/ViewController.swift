//
//  ViewController.swift
//  temporaryImagePicker
//
//  Created by Asmir Abdimazhit  on 5/2/20.
//  Copyright © 2020 Asmir Abdimazhit. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    struct Meme {
      var topText : String
      var bottomText : String
      var originalImage : UIImage
      var memedImage : UIImage
    }
  
  
  
    ///Font Picker View
    let fonts = ["AmericanTypewriter-SemiBold", "Baskerville-SemiBoldItalic", "Chalkduster","Copperplate-Bold","HelveticaNeue-CondensedBlack"]
    var selectedFont : String?
    var selectedSize : Int = 40
    @IBOutlet weak var fontSizeText: UITextField!
    
    
  
  
    var isModifiedTextTop = 0
    var isModifiedTextBottom = 0
    var memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor : UIColor.black,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.font: UIFont(name:"HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -3.0
    ]
    var currentMemeImage : UIImage?
    
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet var chooseFontView: UIView!
    @IBOutlet weak var pickerFont: UIPickerView!
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        unsubscribeToKeyboardHideNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        setTextField(topTextField, "HelveticaNeue-CondensedBlack", 40)
        setTextField(bottomTextField, "HelveticaNeue-CondensedBlack", 40)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotification()
        saveButton.isEnabled = (imagePickerView.image != nil)
        self.chooseFontView.layer.cornerRadius = 10
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerView.contentMode = UIView.ContentMode.scaleAspectFit
        //imagePickerView.contentMode = UIView.ContentMode.center
        topTextField.delegate = self
        bottomTextField.delegate = self
        pickerFont.delegate = self
        /*pickerFont.delegate = self*/
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        print("view Was Disappeared")
        unsubscribeFromKeyboardNotification()
    }
  
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
        }
        dismiss(animated: true, completion: nil)
        saveButton.isEnabled = (imagePickerView.image != nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if isModifiedTextTop == 0 && textField == topTextField {
            topTextField.text = ""
            isModifiedTextTop = 1
        } else if isModifiedTextBottom == 0 && textField == bottomTextField {
            bottomTextField.text = ""
            isModifiedTextBottom = 1
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
            subscribeToKeyboardHideNotification()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
        unsubscribeToKeyboardHideNotification()
    }
    
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotification () {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func subscribeToKeyboardHideNotification () {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardHideNotification () {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: currentMemeImage!)
    }
    
    func generateMemedImage() -> UIImage {
        bottomToolbar.isHidden = true
        topToolbar.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        bottomToolbar.isHidden = false
        topToolbar.isHidden = false
        return memedImage
    }
    
    func setTextField(_ tf: UITextField, _ font: String, _ size: Int){
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor : UIColor.black,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font: UIFont(name: font, size: CGFloat(size))!,
            NSAttributedString.Key.strokeWidth: -3.0
        ]
        tf.defaultTextAttributes = memeTextAttributes
        tf.textAlignment = .center
        
    }
    
    
    @IBAction func sharePressed(_ sender: Any) {
        if saveButton.isEnabled {
            let memedImage = generateMemedImage()
            currentMemeImage = memedImage
            let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
            present(activityViewController, animated: true, completion:  nil)
            activityViewController.completionWithItemsHandler = {(activity,success, items, error) in
                if success {
                    self.save()
                }
            }
        }
    }
    
    @IBAction func cancelViewPressed(_ sender: Any) {
        imagePickerView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        isModifiedTextTop = 0
        isModifiedTextBottom = 0
    }
    
  
    @IBAction func chooseFontPressed(_ sender: Any) {
        chooseFontView.center = view.center
        self.view.addSubview(chooseFontView)
    }
    
    @IBAction func doneFontPressed(_ sender: Any) {
        selectedSize = Int(fontSizeText.text ?? "40") ?? 40
        setTextField(topTextField, selectedFont ?? "HelveticaNeue-CondensedBlack", selectedSize)
        setTextField(bottomTextField, selectedFont ?? "HelveticaNeue-CondensedBlack", selectedSize)
        self.chooseFontView.removeFromSuperview()
    }
    
    
    
}

extension ViewController : UIPickerViewDataSource, UIPickerViewDelegate{


    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fonts.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fonts[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFont = fonts[row]
        //self.chooseFontView.removeFromSuperview()
    }
}


//I am not sure if the places where I observe the keyboardwillappear and keyboarwillhide notifications are right. And the same goes for the shareButton is enabled.
