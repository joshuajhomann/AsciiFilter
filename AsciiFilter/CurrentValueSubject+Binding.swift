//
//  CurrentValueSubject+Binding.swift
//  AsciiFilter
//
//  Created by Joshua Homann on 3/10/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import SwiftUI
import Combine

extension CurrentValueSubject where Failure == Never {
  func makeBinding() -> Binding<Output> {
    .init(get: {self.value}, set: self.send(_:))
  }
}
