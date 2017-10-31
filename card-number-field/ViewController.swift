//
//  ViewController.swift
//  card-number-field
//
//  Created by Leighroy on 30/10/2017.
//  Copyright © 2017 DICE FM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var cardNumberView: CardNumberView!

    @IBAction func scanCardPressed(_ sender: Any) {
        cardNumberView.updateWithCardNumber("378282246310005")
    }
}

