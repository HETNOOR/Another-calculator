//
//  ViewController.swift
//  Another calculator
//
//  Created by Максим Герасимов on 08.10.2024.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var operationHistory: UILabel!
    
    private let viewModel = CalculatorViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.onResultUpdated = { [weak self] resultText in
            self?.result.text = resultText
        }
        
        viewModel.onHistoryUpdated = { [weak self] historyText in
            self?.operationHistory.text = historyText
        }
    }
    
    @IBAction func сhangeSignPressed(_ sender: UIButton) {
        viewModel.handleChangeSign(currentResultText: result.text)
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        viewModel.handleClear()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.currentTitle else { return }
        viewModel.handleButtonPress(buttonText, currentResultText: result.text)
    }
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard let buttonText = sender.accessibilityLabel else { return }
        viewModel.handleOperationPress(buttonText, currentResultText: result.text)
    }
    
    @IBAction func calculateButtonPressed(_ sender: UIButton) {
        viewModel.handleCalculatePress(currentResultText: result.text)
    }
    
}

class RoundedButton: UIButton {

  
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRoundedCorners()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupRoundedCorners()
    }

    private func setupRoundedCorners() {
        self.layer.cornerRadius = self.frame.size.height / 2
        self.layer.masksToBounds = true
    }
}
