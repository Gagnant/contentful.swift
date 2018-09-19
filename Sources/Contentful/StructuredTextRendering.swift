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

public struct Styling {

    public static let `default` = Styling()

    /// The base font with which to begin styling.
    public var baseFont = Font.systemFont(ofSize: Font.systemFontSize)

//    public var monospacedFont = Font.
    public var textColor = Color.black

    public var paragraphStyling = NSParagraphStyle()

    public var indentationMultiplier: CGFloat = 2.0

    public var fontsForHeadingLevels: [Font] = [
        // TODO: determine best structure for easy configuration.
        Font.systemFont(ofSize: 24),
        Font.systemFont(ofSize: 18),
        Font.boldSystemFont(ofSize: 16),
        Font.systemFont(ofSize: 15),
        Font.systemFont(ofSize: 14),
        Font.systemFont(ofSize: 13)
    ]
}

public enum Rendered {
    case string(NSAttributedString)
    case view(View?)
}

extension Swift.Array where Element == Rendered {
    mutating func appendNewlineIfNecessary() {
        // TODO: Determine when this is not necessary: i.e. if all siblings are not homogenous.
        append(Rendered.string(NSAttributedString(string: "\n")))
    }
}
public struct HeadingRenderer: NodeRenderer {

    public func render(node: Node, renderer: DocumentRenderer, context: [CodingUserInfoKey: Any]) -> [Rendered] {
        // TOOD: is there a better abstraction other than force casting?
        let heading = node as! Heading
        var rendered = heading.content.reduce(into: [Rendered]()) { (rendered, node) in
            let nodeRenderer = renderer.renderer(for: node)

            let renderedChildren = nodeRenderer.render(node: node, renderer: renderer, context: context)
            // TODO: Push onto context.
            rendered.append(contentsOf: renderedChildren)
        }

        rendered.appendNewlineIfNecessary()
        return rendered
    }
}

public struct ParagraphRenderer: NodeRenderer {
    public func render(node: Node, renderer: DocumentRenderer, context: [CodingUserInfoKey: Any]) -> [Rendered] {
        // TOOD: is there a better abstraction other than force casting?
        let paragraph = node as! Paragraph
        var rendered = paragraph.content.reduce(into: [Rendered]()) { (rendered, node) in
            let nodeRenderer = renderer.renderer(for: node)

            let renderedChildren = nodeRenderer.render(node: node, renderer: renderer, context: context)
            // TODO: Push onto context.
            rendered.append(contentsOf: renderedChildren)
        }
        rendered.appendNewlineIfNecessary()
        return rendered
    }
}
public struct TextRenderer: NodeRenderer {

    public func render(node: Node, renderer: DocumentRenderer, context: [CodingUserInfoKey: Any]) -> [Rendered] {
        let text = node as! Text
        let styles = context[.styles] as! Styling

        let font = DefaultDocumentRenderer.font(for: text, styling: styles)

        let indentLevel = context[.indentLevel] as! Int
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = CGFloat(indentLevel) * styles.indentationMultiplier


        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]
        let attributedString = NSAttributedString(string: text.value, attributes: attributes)
        return [.string(attributedString)]
    }
}

public struct OrderedListRenderer: NodeRenderer {
    public func render(node: Node, renderer: DocumentRenderer, context: [CodingUserInfoKey: Any]) -> [Rendered] {

        var mutableContext = context
        mutableContext[.indentLevel] = (context[.indentLevel] as! Int) + 1

        // TOOD: is there a better abstraction other than force casting?
        let orderedList = node as! OrderedList
        let rendered = orderedList.content.reduce(into: [Rendered]()) { (rendered, node) in
            let nodeRenderer = renderer.renderer(for: node)

            let renderedChildren = nodeRenderer.render(node: node, renderer: renderer, context: mutableContext)
            // TODO: Push onto context.
            rendered.append(contentsOf: renderedChildren)
        }

        // TODO: Ensure we don't go lower than 0
        mutableContext[.indentLevel] = (context[.indentLevel] as! Int) - 1
        return rendered
    }
}

public struct UnorderedListRenderer: NodeRenderer {
    public func render(node: Node, renderer: DocumentRenderer, context: [CodingUserInfoKey: Any]) -> [Rendered] {
        var mutableContext = context
        mutableContext[.indentLevel] = (context[.indentLevel] as! Int) + 1


        // TOOD: is there a better abstraction other than force casting?
        let unorderedList = node as! UnorderedList
        let rendered = unorderedList.content.reduce(into: [Rendered]()) { (rendered, node) in
            let nodeRenderer = renderer.renderer(for: node)

            let renderedChildren = nodeRenderer.render(node: node, renderer: renderer, context: mutableContext)
            // TODO: Push onto context.
            rendered.append(contentsOf: renderedChildren)
        }

        // TODO: Ensure we don't go lower than 0
        mutableContext[.indentLevel] = (context[.indentLevel] as! Int) - 1
        return rendered
    }
}

public struct EmptyRenderer: NodeRenderer {
    public func render(node: Node, renderer: DocumentRenderer, context: [CodingUserInfoKey: Any]) -> [Rendered] {
        return [Rendered.view(nil)]
    }
}

public struct ListItemRenderer: NodeRenderer {
    public func render(node: Node, renderer: DocumentRenderer, context: [CodingUserInfoKey: Any]) -> [Rendered] {
        let listItem = node as! ListItem

        var rendered = [Rendered]()
        for i in 0..<listItem.content.count {
            let child = listItem.content[i]
            // TODO: Pass in the bullets/numbers to be used.
            rendered.append(Rendered.string(NSAttributedString(string: "\(i+1). ")))
            let nodeRenderer = renderer.renderer(for: child)
            let renderedChildren = nodeRenderer.render(node: child, renderer: renderer, context: context)
            rendered.append(contentsOf: renderedChildren)
        }

        rendered.appendNewlineIfNecessary()

        return rendered
    }
}

public struct HyperlinkRenderer: NodeRenderer {

    public func render(node: Node, renderer: DocumentRenderer, context: [CodingUserInfoKey: Any]) -> [Rendered] {
        let hyperlink = node as! Hyperlink

        let attributes: [NSAttributedStringKey: Any] = [
            .link: hyperlink.data.uri
        ]

        let renderedHyperlinkChildren = hyperlink.content.reduce(into: [Rendered]()) { (rendered, node) in
            let nodeRenderer = renderer.renderer(for: node)
            let renderedChildren = nodeRenderer.render(node: node, renderer: renderer, context: context)
            rendered.append(contentsOf: renderedChildren)
        }

        let hyperlinkString = renderedHyperlinkChildren.reduce(into: NSMutableAttributedString()) { (mutableString, renderedChild) in
            switch renderedChild {
            case .string(let string):
                mutableString.append(string)
            default:
                break
            }
        }
        hyperlinkString.addAttributes(attributes, range: NSRange(location: 0, length: hyperlinkString.length))
        return [Rendered.string(hyperlinkString)]
    }
}

public struct QuoteRenderer: NodeRenderer {
    public func render(node: Node, renderer: DocumentRenderer, context: [CodingUserInfoKey: Any]) -> [Rendered] {
        return [Rendered.string(NSAttributedString(string: "QUOTE_STUB"))]
    }
}

public protocol NodeRenderer {
    func render(node: Node, renderer: DocumentRenderer, context: [CodingUserInfoKey: Any]) -> [Rendered]
}

// TODO: better name for htis
public protocol DocumentRenderer {
    func renderer(for node: Node) -> NodeRenderer
}

public extension CodingUserInfoKey {
    public static let paragraphStyling = CodingUserInfoKey(rawValue: "paragraphStylingKey")!
    public static let indentLevel = CodingUserInfoKey(rawValue: "indentLevelKey")!
    public static let styles = CodingUserInfoKey(rawValue: "stylesKey")!
}

public struct DefaultDocumentRenderer: DocumentRenderer {

    public var headingRenderer: HeadingRenderer
    public var textRenderer: TextRenderer
    public var orderedListRenderer: OrderedListRenderer
    public var unorderedListRenderer: UnorderedListRenderer
    public var quoteRenderer: QuoteRenderer
    public var listItemRenderer: ListItemRenderer
    public var emptyRenderer: EmptyRenderer
    public var paragraphRenderer: ParagraphRenderer
    public var hyperlinkRenderer: HyperlinkRenderer



    public let styling: Styling

    public init(styling: Styling) {
        orderedListRenderer = OrderedListRenderer()
        unorderedListRenderer = UnorderedListRenderer()
        textRenderer = TextRenderer()
        headingRenderer = HeadingRenderer()
        quoteRenderer = QuoteRenderer()
        emptyRenderer = EmptyRenderer()
        listItemRenderer = ListItemRenderer()
        paragraphRenderer = ParagraphRenderer()
        hyperlinkRenderer = HyperlinkRenderer()
        self.styling = styling
    }


    public var baseContext: [CodingUserInfoKey: Any] {
        return [
            .styles: styling,
            .indentLevel: 0
        ]
    }

    public func render(document: Document) -> [Rendered] {
        let context = baseContext
        let rendered = document.content.reduce(into: [Rendered]()) { (rendered, node) in
            let nodeRenderer = self.renderer(for: node)
            // TODO: pass in context
            let renderedNodes = nodeRenderer.render(node: node, renderer: self, context: context)
            rendered.append(contentsOf: renderedNodes)
        }
        return rendered
    }

    // TODO: I could make this a default implementation, but then
    public func renderer(for node: Node) -> NodeRenderer {
        switch node.nodeType {
        case .h1, .h2, .h3, .h4, .h5, .h6:
            return headingRenderer

        case .text:
            return textRenderer
            
        case .paragraph:
            return paragraphRenderer

        case .orderedList:
            return orderedListRenderer

        case .unorderedList:
            return unorderedListRenderer

        case .listItem:
            return listItemRenderer

        case .quote:
            return quoteRenderer

        case .hyperlink:
            return hyperlinkRenderer

        default:
            // TODO: Should i make this function throw for debug mode?
            return emptyRenderer
        }
    }

    // TODO: font for string renderable node...

    public static func font(for textNode: Text, styling: Styling) -> Font {
        let markTypes = textNode.marks.map { $0.type }
        if markTypes.contains(.bold) && markTypes.contains(.italic) {
            return styling.baseFont.italicizedAndBolded()!
        } else if markTypes.contains(.bold) {
            return styling.baseFont.bolded()!
        } else if markTypes.contains(.italic) {
            return styling.baseFont.italicized()!
        } else if markTypes.contains(.code) {
            return styling.baseFont.monospaced()!
        }
        return styling.baseFont
    }
}



// Copied from MarkyMark
public extension Font {

    public func bolded() -> Font? {
        if let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) {
            return Font(descriptor: descriptor, size: pointSize)
        }
        return nil
    }

    public func italicized() -> Font? {
        if let descriptor = fontDescriptor.withSymbolicTraits(.traitItalic) {
            return Font(descriptor: descriptor, size: pointSize)
        }
        return nil
    }

    public func monospaced() -> Font? {
        // TODO: Figure out safer way of grabbing a monospace font from the system.
        return Font(name: "Menlo-Regular", size: pointSize)
    }

    public func italicizedAndBolded() -> Font? {
        if let descriptor = fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold]) {
            return Font(descriptor: descriptor, size: pointSize)
        }
        return nil
    }

    public func resized(to size: CGFloat) -> Font {
        return Font(descriptor: fontDescriptor.withSize(size), size: size)
    }
}
