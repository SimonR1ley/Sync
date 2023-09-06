//
//  HeartBeatShape.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/23.
//

import Foundation

struct HeartShapeHeartBeat : Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        
        path.addLine(to: CGPoint(x: rect.midX/3, y: rect.midY))

        path.addLine(to: CGPoint(x: rect.midX/3, y: (rect.midY+rect.maxY)/2))
                
        path.addLine(to: CGPoint(x: (rect.midX/3) + 20, y: (rect.midY/2)))
        
        path.addLine(to: CGPoint(x: (rect.midX/3) + 20, y: rect.midY))

        path.addLine(to: CGPoint(x: rect.midX-25, y: rect.midY))
        
        path.addCurve(to: CGPoint(x: rect.midX-5, y: -10),
                      control1: CGPoint(x: rect.midX-72, y: 15),
                      control2: CGPoint(x: rect.midX-72, y: -45))
        
        path.addCurve(to: CGPoint(x: rect.midX+20, y: rect.midY),
                      control1: CGPoint(x: rect.midX+65, y: -45),
                      control2: CGPoint(x: rect.midX+65, y: 15))
        
        
        path.addLine(to: CGPoint(x: (rect.maxX+rect.midX)/2, y: rect.midY))

        path.addLine(to: CGPoint(x: (rect.maxX+rect.midX)/2, y: (rect.midY+rect.maxY)/2))
                
        path.addLine(to: CGPoint(x: ((rect.maxX+rect.midX)/2) + 20, y: (rect.midY/2)))

        path.addLine(to: CGPoint(x: ((rect.maxX+rect.midX)/2) + 20, y: rect.midY))
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
