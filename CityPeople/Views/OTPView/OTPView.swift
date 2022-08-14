//
//  OTPView.swift
//  OTPtextField
//
//  Created by Mohit Agrawal on 29/05/20.
//  Copyright © 2020 Mohit Agrawal. All rights reserved.
//

import UIKit

class OTPView: UIStackView {

    private var textFieldArray = [OTPTextField]()
    private var numberOfOTPdigit: Int!
    var otpValue: String {
        textFieldArray.map({$0.text!}).joined()
    }
    
    init(numberOfDigits: Int) {
        super.init(frame: .zero)
        
        self.numberOfOTPdigit = numberOfDigits
        setupStackView()
        setTextFields()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
        setTextFields()
    }
    
    func reset() {
        textFieldArray.forEach({$0.text = ""})
    }
    
    private func setupStackView() {
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .center
        self.distribution = .fillEqually
        self.spacing = 16
    }
    
    private func setTextFields() {
        for i in 0..<numberOfOTPdigit {
            let field = OTPTextField()
        
            textFieldArray.append(field)
            addArrangedSubview(field)
            field.delegate = self
            field.textColor = .cityGreen
            field.backgroundColor = .lightGray.withAlphaComponent(0.2)
            field.placeholder = "-"
            field.layer.opacity = 0.5
            field.textAlignment = .center
            field.font = .font(name: .bold, size: 18)
            field.layer.shadowColor = UIColor.black.cgColor
            field.layer.shadowOpacity = 0.1
            field.keyboardType = .decimalPad
            
            i != 0 ? (field.previousTextField = textFieldArray[i-1]) : ()
            i != 0 ? (textFieldArray[i-1].nextTextFiled = textFieldArray[i]) : ()
        }
    }
}

extension OTPView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let field = textField as? OTPTextField else {
            return true
        }
        if !string.isEmpty {
            field.text = string
            field.resignFirstResponder()
            field.nextTextFiled?.becomeFirstResponder()
            return true
        }
        return true
    }
}

class OTPTextField: UITextField {
    var previousTextField: UITextField?
    var nextTextFiled: UITextField?
    
    override func deleteBackward() {
        text = ""
        previousTextField?.becomeFirstResponder()
    }
}
