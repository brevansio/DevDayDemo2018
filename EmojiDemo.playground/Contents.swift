//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    private var label: UILabel!

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        label = UILabel()
        label.text = "Hello World!"
        label.sizeToFit()
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view
    }

    func updateLabel(attributedText: NSAttributedString) {
        label.attributedText = attributedText
        label.sizeToFit()
    }
}

extension String {
    static let emoticonSet =
        CharacterSet(charactersIn: UnicodeScalar(0x100000)!...UnicodeScalar(0x100100)!)

    func showEmoji() -> NSAttributedString {
        guard let range = self.rangeOfCharacter(from: String.emoticonSet) else {
            return NSMutableAttributedString(string: self)
        }

        let emojiString =
            NSMutableAttributedString(string:String(self[startIndex..<range.lowerBound]))

        let emojiId: UInt32 = self[range].unicodeScalars.first!.value
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "\(emojiId)")
        emojiString.append(NSAttributedString(attachment: attachment))

        let substring = String(self[range.upperBound..<self.endIndex])
        emojiString.append(substring.showEmoji())

        return emojiString
    }
}

// Present the view controller in the Live View window
let myViewController = MyViewController()
PlaygroundPage.current.liveView = myViewController

let attributedText = NSMutableAttributedString(string: "Hello Attributed-World")

// Show an Emoticon
let emoticonUnicode = UnicodeScalar(0x100078)!
let emoticonString = "\(emoticonUnicode)"
attributedText.append(emoticonString.showEmoji())
myViewController.updateLabel(attributedText: attributedText)
