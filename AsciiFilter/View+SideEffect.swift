//
//  View+SideEffect.swift
//  AsciiFilter
//
//  Created by Joshua Homann on 3/10/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import SwiftUI


extension View {
  func sideEffect(_ sideEffect: @escaping () -> Void) -> some View {
    sideEffect()
    return self
  }
}

