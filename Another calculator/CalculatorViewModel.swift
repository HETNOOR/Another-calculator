//
//  CalculatorViewModel.swift
//  Another calculator
//
//  Created by Максим Герасимов on 11.10.2024.
//
import Foundation

enum CalculationError: Error {
    case dividedByZero
}

enum Operation: String {
    case add = "+"
    case subtract = "-"
    case multiply = "x"
    case divide = "/"
    case remainder = "%"
    
    func calculate(_ number1: Double, _ number2: Double) throws -> Double {
        switch self {
        case .add:
            return number1 + number2
        case .subtract:
            return number1 - number2
        case .multiply:
            return number1 * number2
        case .divide:
            if number2 == 0 {
                throw CalculationError.dividedByZero
            }
            return number1 / number2
        case .remainder:
            if number2 == 0 {
                throw CalculationError.dividedByZero
            }
            return number1.truncatingRemainder(dividingBy: number2)
        }
    }
}

enum CalculationHistoryItem {
    case number(Double)
    case operation(Operation)
}



class CalculatorViewModel {
    
    var onResultUpdated: ((String) -> Void)?
    var onHistoryUpdated: ((String) -> Void)?
    
    private var calculationHistory: [CalculationHistoryItem] = []
    private let numberFormatter: NumberFormatter
    
    init() {
        numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
    }
    
    func handleButtonPress(_ buttonText: String, currentResultText: String?) {
        guard var resultText = currentResultText else { return }
        
        if resultText == "Ошибка" {
            resultText = "0"
        }
        
        if buttonText == "," {
            if resultText == "0" {
                resultText = "0,"
            } else if !resultText.contains(",") {
                resultText.append(buttonText)
            }
        } else {
            if resultText == "0" {
                resultText = buttonText
            } else {
                resultText.append(buttonText)
            }
        }
        
        updateResult(resultText)
    }
    
    func handleOperationPress(_ operationText: String, currentResultText: String?) {
        guard
            let buttonOperation = Operation(rawValue: operationText),
            let resultText = currentResultText,
            let labelNumber = numberFormatter.number(from: resultText)?.doubleValue
        else { return }
        
        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))
        updateResult("0")
    }
    
    func handleCalculatePress(currentResultText: String?) {
        guard
            let resultText = currentResultText,
            let labelNumber = numberFormatter.number(from: resultText)?.doubleValue
        else { return }
        
        calculationHistory.append(.number(labelNumber))
        
        do {
            let resulted = try calculate()
            if let formattedResult = numberFormatter.string(from: NSNumber(value: resulted)) {
                updateResult(formattedResult)
                updateHistory()
            }
        } catch {
            updateResult("Ошибка")
        }
        
        calculationHistory.removeAll()
    }
    
    func handleClear() {
        calculationHistory.removeAll()
        updateResult("0")
    }
    
    func handleChangeSign(currentResultText: String?) {
        guard
            let resultText = currentResultText,
            var number = numberFormatter.number(from: resultText)?.doubleValue
        else { return }
        
        number = -number
        let formattedResult = (number.truncatingRemainder(dividingBy: 1) == 0) ? String(Int(number)) : numberFormatter.string(from: NSNumber(value: number))
        updateResult(formattedResult ?? "0")
    }
    
    private func updateResult(_ resultText: String) {
        onResultUpdated?(resultText)
    }
    
    private func updateHistory(_ historyText: String? = nil) {
        let history = historyText ?? buildOperationHistory()
        onHistoryUpdated?(history)
    }
    
    private func buildOperationHistory() -> String {
           var history = ""
           for item in calculationHistory {
               switch item {
               case .number(let number):
                   if let formattedNumber = numberFormatter.string(from: NSNumber(value: number)) {
                       history += "\(formattedNumber) "
                   }
               case .operation(let operation):
                   history += "\(operation.rawValue) "
               }
           }
           return history
       }
    
    private func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0 }
        var currentResult = firstNumber
        
        for index in stride(from: 1, through: calculationHistory.count - 1, by: 2) {
            guard
                case .operation(let operation) = calculationHistory[index],
                case .number(let number) = calculationHistory[index + 1]
            else { break }
            
            currentResult = try operation.calculate(currentResult, number)
        }
        
        return currentResult
    }
}
