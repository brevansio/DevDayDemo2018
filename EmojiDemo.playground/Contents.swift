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

struct Emoji {
    static let terminator = "\(UnicodeScalar(0x10FFFF)!)"
    static let emoticonSet =
        CharacterSet(charactersIn: UnicodeScalar(0x100000)!...UnicodeScalar(0x100100)!)
    static let decomojiSet =
        CharacterSet(charactersIn: UnicodeScalar(0x100100)!..<UnicodeScalar(0x10FFFF)!)
    static let sentinelSet = CharacterSet([UnicodeScalar(0x10FFFF)!])
    static var oldEmojiSet: CharacterSet = {
        var set = Emoji.decomojiSet
        set.formUnion(Emoji.emoticonSet)
        return set
    }()

    let productId: String
    let sticonId: String
    let version: Int

    var start: UInt = UInt.max {
        didSet {
            guard start > 0 else {
                end = UInt.max
                return
            }
            end = start + UInt(copyText.utf16.count)
        }
    }
    private(set) var end: UInt = UInt.max
    let keyword: String

    lazy var imageUrl: URL = {
        return Bundle.main.url(forResource: "\(productId)-\(sticonId)",
                               withExtension: "png")!
    }()

    var copyText: String {
        return "(\(keyword))"
    }

    init(product: String, code: String, replacementText: String, versionNum: Int = 0) {
        productId = product
        sticonId = code
        keyword = replacementText
        version = versionNum
    }
}

/*
extension String {
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
*/

extension CGSize {
    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs,
                      height: lhs.height * rhs)
    }
}

class EmojiAttachment: NSTextAttachment {
    private(set) var emoji: Emoji

    init(emoji metadata: Emoji) {
        emoji = metadata
        let imageData = try! Data(contentsOf: emoji.imageUrl)
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

    func append(to string: NSAttributedString?) -> NSAttributedString {
        let attachmentString = NSAttributedString(attachment: self)
        guard let string = string else {
            emoji.start = 0
            return attachmentString
        }
        let mutableCopy = NSMutableAttributedString(attributedString: string)

        var length = mutableCopy.string.utf16.count

        mutableCopy.enumerateAttribute(.attachment, in: NSRange(0..<mutableCopy.length),
                                       options: []) { (attachment, _, _) in
                                        guard let attachment = attachment as? EmojiAttachment else {
                                            return
                                        }
                                        length += attachment.emoji.copyText.utf16.count
        }
        emoji.start = UInt(length)
        mutableCopy.append(attachmentString)
        return mutableCopy
    }
}

/*
extension NSAttributedString {
    static let EmojiPasteboard = UIPasteboard.Name("emojiPasteboard")
    func copyToPasteboard() {
        var prettyString = self.string
        var internalString = self.string
        enumerateAttributes(in: NSRange(0..<self.length),
                            options: [.reverse]) { (attribute, range, _) in
                                guard let attachment = attribute[.attachment] as? EmojiAttachment else {
                                    return
                                }
                                var index = String.Index(encodedOffset: range.lowerBound)
                                if index > prettyString.endIndex {
                                    index = prettyString.endIndex
                                }
                                prettyString.insert(contentsOf: attachment.copyText,
                                                    at: index)
                                internalString.insert(contentsOf: attachment.formattedText,
                                                      at: index)

        }
        UIPasteboard.general.string = prettyString
        let emojiPasteboard = UIPasteboard(name: NSAttributedString.EmojiPasteboard,
                                           create: true)
        emojiPasteboard?.string = internalString
    }

    static func attributedStringFromClipboard() -> NSAttributedString? {
        let emojiPasteboard =
            UIPasteboard(name: NSAttributedString.EmojiPasteboard,
                         create: false)
        if let internalString = emojiPasteboard?.string {
            return internalString.showEmoji()
        }
        else if let generalString = UIPasteboard.general.string {
            return NSAttributedString(string: generalString)
        }
        else {
            return nil
        }
    }
}
*/

// Present the view controller in the Live View window
let myViewController = MyViewController()
PlaygroundPage.current.liveView = myViewController

let attributedText = NSMutableAttributedString(string: "Hello Attributed-World")

// Show a LINE Emoji
let emoji = Emoji(product: "line", code: "logo", replacementText: "line")
let attachment = EmojiAttachment(emoji: emoji)
myViewController.updateLabel(attributedText: attachment.append(to: attributedText))
