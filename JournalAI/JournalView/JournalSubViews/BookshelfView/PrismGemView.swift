//
//  PrismGemView.swift
//  JournalAI
//
//  Created by Ashesh Patel on 2026-04-05.
//
import SwiftUI

struct PrismGemView: View {
  var body: some View {
    Canvas { context, size in
      let cx = size.width / 2
      let tip = CGPoint(x: cx, y: 2)
      let bl  = CGPoint(x: 2, y: size.height - 2)
      let br  = CGPoint(x: size.width - 2, y: size.height - 2)
      
      var outline = Path()
      outline.move(to: tip); outline.addLine(to: bl)
      outline.addLine(to: br); outline.closeSubpath()
      context.stroke(outline, with: .color(Color(red: 0.62, green: 0.42, blue: 0.82)), lineWidth: 1)
      
      let internalPts: [(CGPoint, CGPoint, Color)] = [
        (tip, CGPoint(x: cx * 0.45, y: size.height - 2), Color(red: 0.48, green: 0.70, blue: 0.98)),
        (tip, CGPoint(x: cx, y: size.height - 2),        Color(red: 0.62, green: 0.42, blue: 0.82)),
        (tip, CGPoint(x: size.width - cx * 0.45, y: size.height - 2), Color(red: 0.98, green: 0.58, blue: 0.40))
      ]
      for (from, to, color) in internalPts {
        var p = Path(); p.move(to: from); p.addLine(to: to)
        context.stroke(p, with: .color(color.opacity(0.55)), lineWidth: 0.8)
        context.fill(
          Path(ellipseIn: CGRect(x: to.x - 2.5, y: to.y - 2.5, width: 5, height: 5)),
          with: .color(color)
        )
      }
    }
  }
}
