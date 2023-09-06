//
//  Quick_View_WidgetBundle.swift
//  Quick View Widget
//
//  Created by Simon Riley on 2023/09/03.
//

import WidgetKit
import SwiftUI

@main
struct Quick_View_WidgetBundle: WidgetBundle {
    var body: some Widget {
        Quick_View_Widget()
        Quick_View_WidgetLiveActivity()
    }
}
