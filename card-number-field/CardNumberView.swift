//
//  CardNumberView.swift
//  card-number-field
//
//  Created by Leighroy on 30/10/2017.
//  Copyright © 2017 DICE FM. All rights reserved.
//

import Foundation
import UIKit

class CardNumberView: UIView {

    /// Initial text view for unrecognised cards
    @IBOutlet weak var singleField: UITextField?

    /// Stack view containing layout for 3 text fields
    @IBOutlet weak var threeFieldsView: UIStackView?

    /// Stack view containing layout for 4 text fields
    @IBOutlet weak var fourFieldsView: UIStackView?

    fileprivate var threeFieldsTextViews: [CardNumberField] {
        guard let views = threeFieldsView?.arrangedSubviews as? [CardNumberField] else {
            return []
        }
        return views
    }

    fileprivate var fourFieldsTextViews: [CardNumberField] {
        guard let views = fourFieldsView?.arrangedSubviews as? [CardNumberField] else {
            return []
        }
        return views
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        singleField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        threeFieldsTextViews.forEach({ $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged) })
        fourFieldsTextViews.forEach({ $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged) })
    }

    /// The current inputted card number
    var cardNumber: String {
        let singleFieldText = singleField?.text ?? ""
        let three = threeFieldsTextViews.flatMap({ $0.text }).joined()
        let four  = fourFieldsTextViews.flatMap({ $0.text }).joined()

        return singleFieldText + three + four
    }
}

// MARK: - UITextFieldDelegate
extension CardNumberView: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag > 0, range.length == -1 {
            switch numberOfFields(forNumber: cardNumber) {
            case 3:
                threeFieldsTextViews[textField.tag - 1].becomeFirstResponder()
            case 4:
                fourFieldsTextViews[textField.tag - 1].becomeFirstResponder()
            default:
                break
            }
        }

        guard let textField = textField as? CardNumberField else {
            return true
        }

        return textField.maxLength != range.location
    }

    @objc func textFieldDidChange(_ textField: CardNumberField) {
        guard let text = textField.text else {
            return
        }

        guard text.characters.count <= 2 else {
            updateTextFieldTarget(textField)
            return
        }

        guard cardNumber.characters.count <= 2 else {
            return
        }

        let numFields = numberOfFields(forNumber: text)
        switch numFields {
        case 3:
            updateForThreeFields(number: text)
        case 4:
            updateForFourFields(number: text)
        case 1 where text.isEmpty:
            updateForSingleField()
        default:
            break
        }
    }

    func updateTextFieldTarget(_ textField: CardNumberField) {
        guard let text = textField.text, text.characters.count == textField.maxLength else {
            return
        }

        let fieldsCount = numberOfFields(forNumber: cardNumber)

        switch (textField.tag, fieldsCount) {
        case (0, 3):
            threeFieldsTextViews[1].becomeFirstResponder()
        case (0, 4):
            fourFieldsTextViews[1].becomeFirstResponder()
        case (1, 3):
            threeFieldsTextViews[2].becomeFirstResponder()
        case (1, 4):
            fourFieldsTextViews[2].becomeFirstResponder()
        case (2, 3):
            print("finished, move onto card expiry")
        case (2, 4):
            fourFieldsTextViews[3].becomeFirstResponder()
        case (3, 4):
            print("finished, move onto next field")
        default:
            break
        }
    }
}

// MARK: - Text Field Layout Changes
private extension CardNumberView {

    /// Update the layout to 1 text field
    func updateForSingleField() {
        guard let field = singleField, field.isHidden else {
            return
        }

        UIView.animate(withDuration: 0.2, animations: {
            self.singleField?.alpha     = 1.0
            self.threeFieldsView?.alpha = 0.0
            self.fourFieldsView?.alpha  = 0.0
        }, completion: { completed in
            self.singleField?.isHidden     = false
            self.threeFieldsView?.isHidden = true
            self.fourFieldsView?.isHidden  = true
        })

        threeFieldsTextViews.forEach({$0.text = ""})
        fourFieldsTextViews.forEach({$0.text = ""})
        singleField?.becomeFirstResponder()
    }

    /// Update the layout to 3 text fields
    ///
    /// - Parameter number: the current inputted number
    func updateForThreeFields(number: String) {
        guard let field = threeFieldsView, field.isHidden else {
            return
        }

        UIView.animate(withDuration: 0.2, animations: {
            self.singleField?.alpha     = 0.0
            self.threeFieldsView?.alpha = 1.0
            self.fourFieldsView?.alpha  = 0.0
        }, completion: { completed in
            self.singleField?.isHidden     = true
            self.threeFieldsView?.isHidden = false
            self.fourFieldsView?.isHidden  = true
        })

        fourFieldsTextViews.forEach({$0.text = ""})

        singleField?.text                = ""
        threeFieldsTextViews.first?.text = number
        threeFieldsTextViews.first?.becomeFirstResponder()
    }

    /// Update the layout to 4 text fields
    ///
    /// - Parameter number: the current inputted number
    func updateForFourFields(number: String) {
        guard let field = fourFieldsView, field.isHidden else {
            return
        }

        UIView.animate(withDuration: 0.2, animations: {
            self.singleField?.alpha     = 0.0
            self.threeFieldsView?.alpha = 0.0
            self.fourFieldsView?.alpha  = 1.0
        }, completion: { completed in
            self.singleField?.isHidden     = true
            self.threeFieldsView?.isHidden = true
            self.fourFieldsView?.isHidden  = false
        })

        threeFieldsTextViews.forEach({$0.text = ""})

        singleField?.text               = ""
        fourFieldsTextViews.first?.text = number
        fourFieldsTextViews.first?.becomeFirstResponder()
    }
}

private extension CardNumberView {

    /// Number of card field blocks the view should be split up to depending on the card number
    ///
    /// - Parameter number: the current inputted card number
    /// - Returns: how many text fields are needed
    func numberOfFields(forNumber number: String) -> Int {
        if number.hasPrefix("4") || number.hasPrefix("5") {
            return 4
        }

        guard number.characters.count >= 2 else {
            return 1
        }

        let index  = number.index(number.startIndex, offsetBy: 2)
        let prefix = String(number.prefix(upTo: index))

        switch prefix {
        case "30", "34", "36", "37", "38", "39":
            return 3
        case "35", "60", "64", "65":
            return 4
        default:
            return 1
        }
    }
}
