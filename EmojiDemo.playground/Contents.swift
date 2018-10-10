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
    static let decomojiSet =
        CharacterSet(charactersIn: UnicodeScalar(0x100100)!..<UnicodeScalar(0x10FFFF)!)
    static let sentinelSet = CharacterSet([UnicodeScalar(0x10FFFF)!])
    static var emojiSet: CharacterSet = {
        var set = String.decomojiSet
        set.formUnion(String.emoticonSet)
        return set
    }()

    func showEmoji() -> NSAttributedString {
        guard let range = self.rangeOfCharacter(from: String.emojiSet) else {
            return NSMutableAttributedString(string: self)
        }

        let emojiString =
            NSMutableAttributedString(string:String(self[startIndex..<range.lowerBound]))

        let packageId: UInt32 = self[range].unicodeScalars.first!.value
        let emojiRange = self[range.upperBound..<endIndex].rangeOfCharacter(from: String.emojiSet)!
        let sentinelRange = self[emojiRange.upperBound..<endIndex].rangeOfCharacter(from: String.sentinelSet)!
        let emojiCode: UInt32 = self[emojiRange].unicodeScalars.first!.value
        let keyword = String(self[emojiRange.upperBound..<sentinelRange.lowerBound])
        let attachment = EmojiAttachment(package: Int(packageId),
                                         code: Int(emojiCode),
                                         replacement: keyword)
        emojiString.append(NSAttributedString(attachment: attachment))

        if sentinelRange.upperBound < self.endIndex {
            let substring = String(self[sentinelRange.upperBound..<self.endIndex])
            emojiString.append(substring.showEmoji())
        }

        return emojiString
    }
}

extension CGSize {
    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs,
                      height: lhs.height * rhs)
    }
}

class EmojiAttachment: NSTextAttachment {
    static let terminator = "\(UnicodeScalar(0x10FFFF)!)"
    let packageId: Int
    let version: Int
    let emojiCode: Int
    let keyword: String

    init(package: Int, code: Int, replacement: String) {
        packageId = (package & 0x00FF00) >> 8
        version = package & 0x0000FF
        emojiCode = code
        keyword = replacement
        let imageUrl = Bundle.main.url(forResource: "\(packageId)-\(emojiCode)",
                                       withExtension: "png")!
        let imageData = try! Data(contentsOf: imageUrl)
        super.init(data: imageData,
                   ofType: "public.image")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func attachmentBounds(for textContainer: NSTextContainer?,
                          proposedLineFragment lineFrag: CGRect,
                          glyphPosition position: CGPoint,
                          characterIndex charIndex: Int) -> CGRect {
        guard let image = UIImage(data: contents!) else {
            return .zero
        }

        var scalingFactor: CGFloat = 1.0
        if lineFrag.height < image.size.height {
            scalingFactor = lineFrag.height / image.size.height
        }

        return CGRect(origin: .zero, size: image.size * scalingFactor)
    }
}

// Present the view controller in the Live View window
let myViewController = MyViewController()
PlaygroundPage.current.liveView = myViewController

let attributedText = NSMutableAttributedString(string: "Hello Attributed-World")

// Show an Emoticon
let packageUnicode = UnicodeScalar(0x103D04)!
let codeUnicode = UnicodeScalar(0x100103)!
let emoticonString = "\(packageUnicode)\(codeUnicode)line logo\(EmojiAttachment.terminator)"
attributedText.append(emoticonString.showEmoji())
myViewController.updateLabel(attributedText: attributedText)
