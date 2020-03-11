//
//  CIImage+Color.swift
//  AsciiFilter
//
//  Created by Joshua Homann on 2/29/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import UIKit

extension CIImage {
  
  private static let context = CIContext()
  private static let filter = CIFilter(name: "CIAreaAverage")!
  private static var reduced = [UInt8](repeating: 0, count: 4)

  var averageRGB: (UInt8, UInt8, UInt8)? {
    guard let (r,g,b,_) = averageRGBA() else {
      return nil
    }
    return (r,g,b)
  }

  var brightness: CGFloat? {
    guard let (r,g,b,_) = averageRGBA() else {
      return nil
    }
    return CGFloat(r) * 0.229 + CGFloat(g) * 0.587 + CGFloat(b) * 0.114
  }

  func brightness(for rect: CGRect) -> CGFloat {
    let (r,g,b,_) = averageRGBA(rect: rect) ?? (0,0,0,0)
    return CGFloat(r) * 0.229 + CGFloat(g) * 0.587 + CGFloat(b) * 0.114
  }

  private func averageRGBA(rect: CGRect? = nil) -> (UInt8, UInt8, UInt8, UInt8)? {
    let filterExtent = rect.map(CIVector.init(cgRect:)) ??
      CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
    Self.filter.setValuesForKeys([kCIInputImageKey: self, kCIInputExtentKey: filterExtent])
    guard let outputImage = Self.filter.outputImage else {
      return nil
    }
    Self.context.render(outputImage, toBitmap: &Self.reduced, rowBytes: 4, bounds: .init(origin: .zero, size: .init(width: 1, height: 1)), format: .RGBA8, colorSpace: nil)
    return (Self.reduced[0], Self.reduced[1], Self.reduced[2], Self.reduced[3])
  }
}

