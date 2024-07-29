import _Parser
import LaTeXSwiftUI
import SwiftUI

extension Sequence where Element == InlineNode {
    @MainActor func renderText(
        baseURL: URL?,
        textStyles: InlineTextStyles,
        images: [String: Image],
        attributes: AttributeContainer,
        displayScale: CGFloat
    ) -> Text {
        var renderer = TextInlineRenderer(
            baseURL: baseURL,
            textStyles: textStyles,
            images: images,
            attributes: attributes,
            displayScale: displayScale
        )
        renderer.render(self)
        return renderer.result
    }
}

private struct TextInlineRenderer {
    var result = Text("")
    private let baseURL: URL?
    private let textStyles: InlineTextStyles
    private let images: [String: Image]
    private let attributes: AttributeContainer
    private var shouldSkipNextWhitespace = false
    private var displayScale: CGFloat
    init(
        baseURL: URL?,
        textStyles: InlineTextStyles,
        images: [String: Image],
        attributes: AttributeContainer,
        displayScale: CGFloat
    ) {
        self.baseURL = baseURL
        self.textStyles = textStyles
        self.images = images
        self.attributes = attributes
        self.displayScale = displayScale
    }

    @MainActor mutating func render<S: Sequence>(_ inlines: S) where S.Element == InlineNode {
        for inline in inlines {
            self.render(inline)
        }
    }

    @MainActor private mutating func render(_ inline: InlineNode) {
        switch inline {
        case .text(let content):
            self.renderText(content)
        case .softBreak:
            self.renderSoftBreak()
        case .html(let content):
            self.renderHTML(content)
        case .image(let source, _):
            self.renderImage(source)
        case .math(let source):
            self.renderMath(source)
        default:
            self.defaultRender(inline)
        }
    }

    private mutating func renderText(_ text: String) {
        var text = text

        if self.shouldSkipNextWhitespace {
            self.shouldSkipNextWhitespace = false
            text = text.replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
        }

        self.defaultRender(.text(text))
    }

    private mutating func renderSoftBreak() {
        if self.shouldSkipNextWhitespace {
            self.shouldSkipNextWhitespace = false
        } else {
            self.defaultRender(.softBreak)
        }
    }

    private mutating func renderHTML(_ html: String) {
        let tag = HTMLTag(html)

        switch tag?.name.lowercased() {
        case "br":
            self.defaultRender(.lineBreak)
            self.shouldSkipNextWhitespace = true
        default:
            self.defaultRender(.html(html))
        }
    }

    private mutating func renderImage(_ source: String) {
        if let image = self.images[source] {
            self.result = self.result + Text(image)
        }
    }

    @MainActor private mutating func renderMath(_ source: String) {
        self.result =
            self.result + self.mathcover(source)
    }

    @MainActor private func mathcover(_ source: String) -> Text {
        return self.text(source: "$\(source)$")
    }

    @MainActor private func text(source: String) -> Text {
        var lateRender = LatexRenderer()
        if self.isCached(latex: source, renderer: lateRender, unencodeHTML: false, parsingMode: .onlyEquations, errorMode: .original, processEscapes: false, font: .body, displayScale: self.displayScale) {
         return  self.bodyWithBlocks(self.renderSync(latex: source, renderer: lateRender, unencodeHTML: false, parsingMode: .onlyEquations, errorMode: .original, processEscapes: false, font: .body, displayScale: self.displayScale), forceInline: false, latex: source, renderer: lateRender, unencodeHTML: false, parsingMode: .onlyEquations, errorMode: .original, processEscapes: false, font: .body, displayScale: self.displayScale)
        }else {
          return  self.bodyWithBlocks(self.renderSync(latex: source, renderer: lateRender, unencodeHTML: false, parsingMode: .onlyEquations, errorMode: .original, processEscapes: false, font: .body, displayScale: self.displayScale), forceInline: false, latex: source, renderer: lateRender, unencodeHTML: false, parsingMode: .onlyEquations, errorMode: .original, processEscapes: false, font: .body, displayScale: self.displayScale)
        }
    }

    @MainActor @ViewBuilder private func bodyWithBlocks(_ blocks: [LatexComponentBlock], forceInline: Bool, latex: String,
                                                        renderer: LatexRenderer,
                                                        unencodeHTML: Bool,
                                                        parsingMode: LaTeX.ParsingMode,
                                                        errorMode: LaTeX.ErrorMode,
                                                        processEscapes: Bool,
                                                        font: Font,
                                                        displayScale: CGFloat) -> Text
    {
        blocks.map { block in
            block.isEquationBlock && !forceInline ?
                Text("\n") + self.textImage(for: block, renderer: renderer, unencodeHTML: unencodeHTML, parsingMode: parsingMode, errorMode: errorMode, processEscapes: processEscapes, font: font, displayScale: displayScale) + Text("\n") :
                self.textImage(for: block, renderer: renderer, unencodeHTML: unencodeHTML, parsingMode: parsingMode, errorMode: errorMode, processEscapes: processEscapes, font: font, displayScale: displayScale)
        }.reduce(Text(""), +)
    }

    @MainActor func textImage(for block: LatexComponentBlock, renderer: LatexRenderer,
                              unencodeHTML: Bool,
                              parsingMode: LaTeX.ParsingMode,
                              errorMode: LaTeX.ErrorMode,
                              processEscapes: Bool,
                              font: Font,
                              displayScale: CGFloat) -> Text
    {
        block.toText(
            using: renderer,
            font: font,
            displayScale: self.displayScale,
            renderingMode: .template,
            errorMode: .error,
            blockRenderingMode: .blockViews
        )
    }

    private func isCached(
        latex: String,
        renderer: LatexRenderer,
        unencodeHTML: Bool,
        parsingMode: LaTeX.ParsingMode,
        errorMode: LaTeX.ErrorMode,
        processEscapes: Bool,
        font: Font,
        displayScale: CGFloat
    ) -> Bool {
        renderer.isCached(
            latex: latex,
            unencodeHTML: unencodeHTML,
            parsingMode: parsingMode,
            processEscapes: processEscapes,
            errorMode: errorMode,
            font: font,
            displayScale: displayScale
        )
    }

    private func renderSync(latex: String,
                            renderer: LatexRenderer,
                            unencodeHTML: Bool,
                            parsingMode: LaTeX.ParsingMode,
                            errorMode: LaTeX.ErrorMode,
                            processEscapes: Bool,
                            font: Font,
                            displayScale: CGFloat) -> [LatexComponentBlock]
    {
        renderer.renderSync(
            latex: latex,
            unencodeHTML: unencodeHTML,
            parsingMode: parsingMode,
            processEscapes: processEscapes,
            errorMode: errorMode,
            font: font,
            displayScale: displayScale
        )
    }

    private mutating func defaultRender(_ inline: InlineNode) {
        self.result =
            self.result
                + Text(
                    inline.renderAttributedString(
                        baseURL: self.baseURL,
                        textStyles: self.textStyles,
                        attributes: self.attributes
                    )
                )
    }
}
