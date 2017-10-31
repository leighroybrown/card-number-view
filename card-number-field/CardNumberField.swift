//
//  CardNumberField.swift
//  card-number-field
//
//  Created by Leighroy on 31/10/2017.
//  Copyright © 2017 DICE FM. All rights reserved.
//

import UIKit

class CardNumberField: UITextField {

    /// The maximum digit length of the text field
    @IBInspectable var maxLength: Int = 4

    override func deleteBackward() {
        super.deleteBackward()
        if let text = text, text.isEmpty {
            let _ = delegate?.textField!(self, shouldChangeCharactersIn: NSRange(location: 0, length: -1), replacementString: "")
        }
    }
}
