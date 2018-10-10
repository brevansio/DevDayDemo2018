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

// Present the view controller in the Live View window
let myViewController = MyViewController()
PlaygroundPage.current.liveView = myViewController

let attributedText = NSMutableAttributedString(string: "Hello Attributed-World")

/*
// NSTextAttachment - The Easy Way
let attachment = NSTextAttachment()
let image = UIImage(named: "1048696.png")
attachment.image = image
let emojiString = NSAttributedString(attachment: attachment)
attributedText.append(emojiString)
myViewController.updateLabel(attributedText: attributedText)
*/

// NSTextAttachment - The Designated Way
let url = Bundle.main.url(forResource: "1048696",
                          withExtension: "png")!
let data = try! Data.init(contentsOf: url, options: [])
let attachment = NSTextAttachment(data: data,
                                  ofType: "public.image")
let emojiString = NSAttributedString(attachment: attachment)
attributedText.append(emojiString)
myViewController.updateLabel(attributedText: attributedText)
