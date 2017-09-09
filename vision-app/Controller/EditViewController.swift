//
//  EditViewController.swift
//  vision-app
//
//  Created by Jennifer Vilanda Hasler on 9/6/2560 BE.
//  Copyright © 2560 Jennifer Vilanda Hasler. All rights reserved.
//

import Foundation
import UIKit
import AVKit


class EditViewController: UIViewController, UITabBarDelegate {
    
    @IBOutlet var textView: UITextView!
    let text = "TEXT"
    var adjArray = [String]()
    var verbArray = [String]()
    var nounArray = [String]()

    override func viewDidLoad() {
       print("text in edit is\(textInEdit)")
        textView.text = textInEdit
        
        let tagger = NSLinguisticTagger(tagSchemes: [.lexicalClass], options: 0)
        tagger.string = textView.text
        let omitOptions: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
        let range = NSRange(location: 0, length: textView.text.characters.count)
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: omitOptions) { ( tags, range, stop) in
            let lexical = (textView.text as NSString).substring(with: range)
            
            if tags == NSLinguisticTag.adjective{
                adjArray.append(lexical)
            }
            if tags == NSLinguisticTag.verb{
                verbArray.append(lexical)
            }
            if tags == NSLinguisticTag.noun{
                nounArray.append(lexical)
            }
           
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1{
            print("on adj")
            let string = textView.text
            let attributedString = string?.highlight(adjArray, this: .red)
            textView.attributedText = attributedString
            textView.font = UIFont(name: "Avenir Next", size: 19)
        }else if item.tag == 2{
            print("on verb")
            let string = textView.text
            let attributedString = string?.highlight(verbArray, this: .blue)
            textView.attributedText = attributedString
            textView.font = UIFont(name: "Avenir Next", size: 19)
        }else if item.tag == 3{
            print("on noun")
            let string = textView.text
            let attributedString = string?.highlight(nounArray, this: .green)
            textView.attributedText = attributedString
            textView.font = UIFont(name: "Avenir Next", size: 19)
        }else if item.tag == 4{
            
        }
        
    }
  
}
extension String {
    func getRanges(of string: String) -> [NSRange] {
        var ranges:[NSRange] = []
        if contains(string) {
            let words = self.components(separatedBy: " ")
            var position:Int = 0
            for word in words {
                if word.lowercased() == string.lowercased() {
                    let startIndex = position
                    let endIndex = word.characters.count
                    let range = NSMakeRange(startIndex, endIndex)
                    ranges.append(range)
                }
                position += (word.characters.count + 1) // +1 for space
            }
        }
        return ranges
    }
    func highlight(_ words: [String], this color: UIColor) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for word in words {
            let ranges = getRanges(of: word)
            for range in ranges {
                attributedString.addAttributes([NSAttributedStringKey.foregroundColor: color], range: range)
            }
        }
        return attributedString
    }
}
