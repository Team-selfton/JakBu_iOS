//
//  JakBuWidgetBundle.swift
//  JakBuWidget
//
//  Created by 이지훈 on 12/10/25.
//

import WidgetKit
import SwiftUI

@main
struct JakBuWidgetBundle: WidgetBundle {
    var body: some Widget {
        JakBuWidget()
        JakBuWidgetControl()
        JakBuWidgetLiveActivity()
    }
}
