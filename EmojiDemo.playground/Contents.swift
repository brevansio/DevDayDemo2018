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

struct Emoji: Encodable {
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

    enum CodingKeys: String, CodingKey {
        case productId, sticonId, version
        case start = "S"
        case end = "E"
    }

    init?(from dictionary: [String: Any], attachedTo string: String) {
        guard let productValue = dictionary[CodingKeys.productId.rawValue] as? String,
            let sticonValue = dictionary[CodingKeys.sticonId.rawValue] as? String,
            let versionNum = dictionary[CodingKeys.version.rawValue] as? Int,
            let startValue = dictionary[CodingKeys.start.rawValue] as? Int,
            let endValue = dictionary[CodingKeys.end.rawValue] as? Int else {
                return nil
        }

        let startIndex = String.Index(encodedOffset: startValue)
        let endIndex = String.Index(encodedOffset: endValue)
        let keyword = String(string[startIndex..<endIndex])
                            .trimmingCharacters(in: CharacterSet(["(", ")"]))
        self.init(product: productValue, code: sticonValue, replacementText: keyword, versionNum: versionNum)
        start = UInt(startValue)
        end = UInt(endValue)
    }
}

extension String {
    func show(emoji emojiList: [Emoji]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for emoji in emojiList.sorted(by: { $0.start > $1.start }) {
            let attachment = EmojiAttachment.init(emoji: emoji)
            attributedString.replaceCharacters(in: NSRange(emoji.start..<emoji.end),
                                               with: NSAttributedString(attachment: attachment))
        }
        return attributedString
    }


    /*
    func showEmoji() -> NSAttributedString {
        guard let range = self.rangeOfCharacter(from: Emoji.emojiSet) else {
            return NSMutableAttributedString(string: self)
        }

        let emojiString =
            NSMutableAttributedString(string:String(self[startIndex..<range.lowerBound]))

        let packageId: UInt32 = self[range].unicodeScalars.first!.value
        let emojiRange = self[range.upperBound..<endIndex].rangeOfCharacter(from: Emoji.emojiSet)!
        let sentinelRange = self[emojiRange.upperBound..<endIndex].rangeOfCharacter(from: Emoji.sentinelSet)!
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
    */
}

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

extension NSAttributedString {
    static let EmojiPasteboard = UIPasteboard.Name("emojiPasteboard")
    func copyToPasteboard() {
        var prettyString = self.string
        var emojiList = [Emoji]()
        enumerateAttributes(in: NSRange(0..<self.length),
                            options: [.reverse]) { (attribute, range, _) in
                                guard let attachment = attribute[.attachment] as? EmojiAttachment else {
                                    return
                                }
                                var index = String.Index(encodedOffset: range.lowerBound)
                                if index > prettyString.endIndex {
                                    index = prettyString.endIndex
                                }
                                prettyString.insert(contentsOf: attachment.emoji.copyText,
                                                    at: index)
                                emojiList.append(attachment.emoji)
        }
        UIPasteboard.general.string = prettyString

        if !emojiList.isEmpty {
            let emojiPasteboard = UIPasteboard(name: NSAttributedString.EmojiPasteboard,
                                               create: true)
            let emojiData = try! JSONEncoder().encode(emojiList)
            emojiPasteboard?.setData(emojiData, forPasteboardType: "public.string")
        }
    }

    static func attributedStringFromClipboard() -> NSAttributedString? {

        guard let generalString = UIPasteboard.general.string else {
            return nil
        }

        let emojiPasteboard =
            UIPasteboard(name: NSAttributedString.EmojiPasteboard,
                         create: false)
        let emojiList: [Emoji]
        if let emojiData = emojiPasteboard?.data(forPasteboardType: "public.string"),
        let emojiDictionaries = (try? JSONSerialization.jsonObject(with: emojiData, options: [])) as? [[String: Any]] {
            emojiList = emojiDictionaries.compactMap { Emoji(from: $0, attachedTo: generalString) }
        }
        else {
            emojiList = []
        }

        return generalString.show(emoji: emojiList)
    }
}

// Present the view controller in the Live View window
let myViewController = MyViewController()
PlaygroundPage.current.liveView = myViewController

let attributedText = NSMutableAttributedString(string: "Hello Attributed-World")

// Show a LINE Emoji

let recievedString = "Hello Attributed-World(line logo)"
let decodedEmojiData = [["S": 22, "E": 33, "productId": "line", "sticonId": "logo", "version": 8]]
let recievedEmoji = decodedEmojiData.compactMap { Emoji(from: $0, attachedTo: recievedString) }


let emoji = Emoji(product: "line", code: "logo", replacementText: "line logo")
let attachment = EmojiAttachment(emoji: emoji)
attachment.append(to: attributedText).copyToPasteboard()
myViewController.updateLabel(attributedText: NSAttributedString.attributedStringFromClipboard()!)
