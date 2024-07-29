import Foundation
import Markdown

public extension Array where Element == BlockNode {
    init(markdown: String) {
        let document = Document(parsing: markdown, options: .parseBlockDirectives)
        var storage: [SomeNode] = []
        storage.reserveCapacity(document.childCount)
        self.init(storage.visit(document).compactMap(\.blockNode))
    }
}

public enum SomeNode {
    case blockNode(BlockNode)
    case inlineNode(InlineNode)
    var blockNode: BlockNode? {
        switch self {
        case .blockNode(let node): return node
        case .inlineNode: return nil
        }
    }

    var inlineNode: InlineNode? {
        switch self {
        case .inlineNode(let node): return node
        case .blockNode:
            return nil
        }
    }
}

extension Array: MarkupVisitor where Element == SomeNode {
    public mutating func defaultVisit(_ markup: Markdown.Markup) -> [SomeNode] {
        var nodes: [SomeNode] = []
        for child in markup.children {
            nodes.append(contentsOf: visit(child))
        }

        return nodes
    }

    public mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> [SomeNode] {
        var nodes: [SomeNode] = []

        for child in blockQuote.children {
            nodes.append(contentsOf: visit(child))
        }

        return [.blockNode(.blockquote(children: nodes.compactMap(\.blockNode)))]
    }

    public func visitCodeBlock(_ codeBlock: CodeBlock) -> [SomeNode] {
        [.blockNode(.codeBlock(fenceInfo: codeBlock.language, content: codeBlock.code))]
    }

    public mutating func visitHeading(_ heading: Heading) -> [SomeNode] {
        var nodes: [SomeNode] = []

        for child in heading.children {
            nodes.append(contentsOf: visit(child))
        }

        return [.blockNode(.heading(level: heading.level, content: nodes.compactMap(\.inlineNode)))]
    }

    public func visitThematicBreak(_ thematicBreak: ThematicBreak) -> [SomeNode] {
        [.blockNode(.thematicBreak)]
    }

    public func visitHTMLBlock(_ html: HTMLBlock) -> [SomeNode] {
        [.blockNode(.htmlBlock(content: html.rawHTML))]
    }

    public mutating func visitOrderedList(_ orderedList: OrderedList) -> [SomeNode] {
        var items: [RawTaskListItem] = []
        var isTaskList = false

        for item in orderedList.listItems {
            if !isTaskList && item.checkbox != nil { isTaskList = true }
            items.append(RawTaskListItem(
                isCompleted: item.checkbox == .checked,
                children: item.children.flatMap { visit($0) }.compactMap(\.blockNode)
            ))
        }

        if isTaskList {
            return [.blockNode(.taskList(isTight: true, items: items))]
        }

        return [.blockNode(.numberedList(
            isTight: true,
            start: Int(orderedList.startIndex),
            items: items.map { .init(children: $0.children) }
        ))]
    }

    public mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> [SomeNode] {
        var items: [RawTaskListItem] = []
        var isTaskList = false

        for item in unorderedList.listItems {
            if !isTaskList && item.checkbox != nil { isTaskList = true }
            items.append(RawTaskListItem(
                isCompleted: item.checkbox == .checked,
                children: item.children.flatMap { visit($0) }.compactMap(\.blockNode)
            ))
        }

        if isTaskList {
            return [.blockNode(.taskList(isTight: true, items: items))]
        }

        return [.blockNode(.bulletedList(isTight: true, items: items.map {
            .init(children: $0.children)
        }))]
    }

    public mutating func visitParagraph(_ paragraph: Paragraph) -> [SomeNode] {
        var items: [InlineNode] = []
        for item in paragraph.children {
            items.append(contentsOf: visit(item).compactMap(\.inlineNode))
        }
        return [.blockNode(.paragraph(content: items))]
    }

    public func visitInlineCode(_ inlineCode: InlineCode) -> [SomeNode] {
        [.inlineNode(.code(inlineCode.code))]
    }

    public mutating func visitEmphasis(_ emphasis: Emphasis) -> [SomeNode] {
        var nodes: [InlineNode] = []

        for child in emphasis.children {
            nodes.append(contentsOf: visit(child).compactMap(\.inlineNode))
        }

        return [.inlineNode(.emphasis(children: nodes))]
    }

    public mutating func visitImage(_ image: Image) -> [SomeNode] {
        var nodes: [InlineNode] = []

        for child in image.children {
            nodes.append(contentsOf: visit(child).compactMap(\.inlineNode))
        }

        return [.inlineNode(.image(source: image.source ?? "", children: nodes))]
    }

    public func visitInlineHTML(_ inlineHTML: InlineHTML) -> [SomeNode] {
        [.inlineNode(.html(inlineHTML.rawHTML))]
    }

    public func visitLineBreak(_ lineBreak: LineBreak) -> [SomeNode] {
        [.inlineNode(.lineBreak)]
    }

    public mutating func visitLink(_ link: Link) -> [SomeNode] {
        var nodes: [InlineNode] = []

        for child in link.children {
            nodes.append(contentsOf: visit(child).compactMap(\.inlineNode))
        }

        return [.inlineNode(.link(destination: link.destination ?? "", children: nodes))]
    }

    public func visitSoftBreak(_ softBreak: SoftBreak) -> [SomeNode] {
        [.inlineNode(.softBreak)]
    }

    public mutating func visitStrong(_ strong: Strong) -> [SomeNode] {
        var nodes: [InlineNode] = []

        for child in strong.children {
            nodes.append(contentsOf: visit(child).compactMap(\.inlineNode))
        }

        return [.inlineNode(.strong(children: nodes))]
    }

    public func visitText(_ text: Text) -> [SomeNode] {
        return [.inlineNode(.text(text.string))]
    }

    public mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> [SomeNode] {
        var nodes: [InlineNode] = []

        for child in strikethrough.children {
            nodes.append(contentsOf: visit(child).compactMap(\.inlineNode))
        }

        return [.inlineNode(.strikethrough(children: nodes))]
    }

    public mutating func visitTable(_ table: Table) -> [SomeNode] {
        let alignments = table.columnAlignments.map { alignment -> RawTableColumnAlignment in
            switch alignment {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            case nil: return .none
            }
        }

        var headCells: [RawTableCell] = []
        for cell in table.head.cells {
            headCells.append(.init(content: cell.children.flatMap { visit($0) }.compactMap(\.inlineNode)))
        }

        var rows: [RawTableRow] = [.init(cells: headCells)]
        for row in table.body.rows {
            var cells: [RawTableCell] = []
            for cell in row.cells {
                var nodes: [InlineNode] = []

                for child in cell.children {
                    nodes.append(contentsOf: visit(child).compactMap(\.inlineNode))
                }

                cells.append(RawTableCell(content: nodes))
            }
            rows.append(RawTableRow(cells: .init(cells)))
        }
        return [.blockNode(.table(columnAlignments: alignments, rows: .init(rows)))]
    }

    public mutating func visitMathBlock(_ mathBlock: MathBlock) -> [SomeNode] {
        [.inlineNode(.math(mathBlock.math))]
    }
}
