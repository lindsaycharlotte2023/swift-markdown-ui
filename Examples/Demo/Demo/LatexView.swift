//
//  LatexView.swift
//  Demo
//
//  Created by facebook on 29/7/2024.
//

import SwiftUI
import MarkdownUI

struct LatexView: View {
  var body: some View {
    DemoView {
      Markdown("Let\'s break down each part of the mathematical expressions provided:\n\n1. **Standard Deviation Formula:**\n\n$$\\sigma = \\sqrt{\\frac{1}{N}\\sum_{i=1}^N (x_i - \\mu)^2}$$\n\nThis represents the standard deviation $$( \\sigma )$$ of a set of values $$( x_i )$$, where $$( \\mu )$$ is the mean of the values, and $$( N )$$ is the number of values.\n\n2. **Matrix:**\n\n$$\\begin{pmatrix}a_{11} & a_{12} & a_{13} & a_{14} \\\\a_{21} & a_{22} & a_{23} & a_{24} \\\\a_{31} & a_{32} & a_{33} & a_{34} \\\\a_{41} & a_{42} & a_{43} & a_{44}\\end{pmatrix}$$\n\nThis is a $$( 4 \\times 4 )$$ matrix with elements $$( a_{ij} )$$ where $$( i )$$ denotes the row and $$( j )$$ denotes the column.\n\n3. **Cross Product of Vectors:**\n\n$$\\vec{\\mathbf{V}}_1 \\times \\vec{\\mathbf{V}}_2 = \\begin{vmatrix}\\hat{\\imath} & \\hat{\\jmath} & \\hat{k} \\\\\\frac{\\partial X}{\\partial u} & \\frac{\\partial Y}{\\partial u} & 0 \\\\\\frac{\\partial X}{\\partial v} & \\frac{\\partial Y}{\\partial v} & 0\\end{vmatrix}$$\n\nThis is the determinant used to find the cross product of two vectors $$(\\vec{\\mathbf{V}}_1)$$ and $$(\\vec{\\mathbf{V}}_2)$$ in terms of partial derivatives with respect to $$( u )$$ and $$( v )$$. The unit vectors $$( \\hat{\\imath} )$$, $$( \\hat{\\jmath} )$$, and $$( \\hat{k} )$$ represent the x, y, and z axes, respectively.\n\nCorrecting the matrix formatting for better readability:\n\nFor the $$( 4 \\times 4 )$$ matrix:\n\n$$\\begin{pmatrix}a_{11} & a_{12} & a_{13} & a_{14} \\\\a_{21} & a_{22} & a_{23} & a_{24} \\\\a_{31} & a_{32} & a_{33} & a_{34} \\\\a_{41} & a_{42} & a_{43} & a_{44}\\end{pmatrix}$$\n\nFor the cross product determinant:\n\n")
    }
  }
}

#Preview {
    LatexView()
}
