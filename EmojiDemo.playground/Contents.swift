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
myViewController.updateLabel(attributedText: attributedText)

