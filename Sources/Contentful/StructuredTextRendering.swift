//
//  StructuredTextRendering.swift
//  Contentful
//
//  Created by JP Wright on 29.08.18.
//  Copyright © 2018 Contentful GmbH. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

#if os(iOS) || os(tvOS) || os(watchOS)
/// If building for iOS, tvOS, or watchOS, `View` aliases to `UIView`. If building for macOS
/// `View` aliases to `NSView`
public typealias Color = UIColor
public typealias Font = UIFont
public typealias FontDescriptor = UIFontDescriptor
public typealias View = UIView
#else
/// If building for iOS, tvOS, or watchOS, `View` aliases to `UIView`. If building for macOS
/// `View` aliases to `NSView`
public typealias Color = NSColor
public typealias Font = NSFont
public typealias FontDescriptor = NSFontDescriptor
public typealias View = NSView
#endif


public protocol StyleConfigurable {
    var font: Font { get set }
    var textColor: Color    { get set }
}

public struct Styling {

    /// The base font with which to begin styling.
    public var baseFont = Font.systemFont(ofSize: Font.systemFontSize)

    public var textColor = Color.black

    public var paragraphStyling = ParagraphStyling()
    public var italicStyling = ItalicStyling()
    public var boldStyling = BoldStyling()
    public var headingStyling = HeadingStyling()
    public var listStyling = ListStyling()
    public var linkStyling = LinkStyling()
    public var inlineCodeBlockStyling = InlineCodeStyling()

//    public var strikeThroughStyling = StrikeThroughStyling()
//    public var imageStyling = ImageStyling()
//    public var horizontalLineStyling = HorizontalLineStyling()
//    public var codeBlockStyling = CodeBlockStyling()
//    public var quoteStyling = QuoteStyling()
}

public struct ParagraphStyling {}
public struct ItalicStyling {}
public struct BoldStyling {}
public struct HeadingStyling {

    public var fontsForLevels: [Font] = [
        // TODO: determine best structure for easy configuration.
        Font.systemFont(ofSize: 24),
        Font.systemFont(ofSize: 18),
        Font.boldSystemFont(ofSize: 16),
        Font.systemFont(ofSize: 15),
        Font.systemFont(ofSize: 14),
        Font.systemFont(ofSize: 13)
    ]
}
public struct StrikeThroughStyling {}
public struct ListStyling {}
public struct LinkStyling {}
public struct InlineCodeStyling {}
//
//// Copied from MarkyMark
//public extension Font {
//
//    public func bolded() -> Font? {
//        if let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) {
//            return Font(descriptor: descriptor, size: pointSize)
//        }
//
//        return nil
//    }
//
//    public func italicized() -> Font? {
//        if let descriptor = fontDescriptor.withSymbolicTraits(.traitItalic) {
//            return Font(descriptor: descriptor, size: pointSize)
//        }
//
//        return nil
//    }
//
//    public func italicizedAndBolded() -> Font? {
//        if let descriptor = fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold]) {
//            return Font(descriptor: descriptor, size: pointSize)
//        }
//
//        return nil
//    }
//
//    public func resized(to size: CGFloat) -> Font {
//        return Font(descriptor: fontDescriptor.withSize(size), size: size)
//    }
//}


//protocol NodeViewConfigurable {
//    associatedtype NodeType: Node
//
//    func configure(node: NodeType)
//}
//
//protocol NodeViewFactory {
//    associatedtype ViewType: NodeViewConfigurable
//
//    func view(for node: ViewType.NodeType) -> View
//}

public struct MarkedTextRenderer {

    public static func attributedString(for block: BlockNode) -> NSAttributedString {

        let mutableString = NSMutableAttributedString()

        for node in block.content {
            // Break if we've finished rendering all inline or text nodes.
            switch node.nodeClass {
            case .text:
                let text = node as! Text
//                let markAttributes: [NSAttributedStringKey: Any] = [.font: MarkedTextRenderer.font(for: text, styling: Styling())!]
//                let attributedString = NSAttributedString(string: text.value, attributes: markAttributes)
//                mutableString.append(attributedString)

            case .inline:
                // Get embeded entry.
                break

            case .document:
                fatalError()

            case .block:
                break
            }
        }
        return mutableString
    }
//
//    public static func font(for textNode: Text, styling: Styling) -> Font? {
//        let markTypes = textNode.marks.map { $0.type }
//        if markTypes.contains(.bold) && markTypes.contains(.italic) {
//            return styling.baseFont.italicizedAndBolded()
//        } else if markTypes.contains(.bold) {
//            return styling.baseFont.bolded()
//        } else if markTypes.contains(.italic) {
//            return styling.baseFont.italicized()
//        } else if markTypes.contains(.code) {
//            // TODO: Use monospaced font?
//        }
//        return nil
//    }
}
