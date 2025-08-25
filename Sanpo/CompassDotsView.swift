import SwiftUI

struct CompassDotsView: View {
    @StateObject private var compass = CompassManager()
    @State private var previousHeading: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                let fullScreenRect = geo.frame(in: .global)
                let heading = compass.heading
                let padding: CGFloat = 6
                let cornerRadius: CGFloat = 52
                let rect = fullScreenRect.insetBy(dx: padding, dy: padding)
                
                // Outline for debugging - uses the inset rect
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                
                // North
                CompassDot(
                    color: .red,
                    rect: rect,
                    padding: 0,
                    cornerRadius: cornerRadius,
                    angle: -heading,
                    previousAngle: -previousHeading
                )
                
                // East
                CompassDot(
                    color: .white,
                    rect: rect,
                    padding: 0,
                    cornerRadius: cornerRadius,
                    angle: 90 - heading,
                    previousAngle: 90 - previousHeading
                )
                
                // South
                CompassDot(
                    color: .white,
                    rect: rect,
                    padding: 0,
                    cornerRadius: cornerRadius,
                    angle: 180 - heading,
                    previousAngle: 180 - previousHeading
                )
                
                // West
                CompassDot(
                    color: .white,
                    rect: rect,
                    padding: 0,
                    cornerRadius: cornerRadius,
                    angle: 270 - heading,
                    previousAngle: 270 - previousHeading
                )
                
                // Center clock demo
                Text("9:41")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .ignoresSafeArea()
        .onChange(of: compass.heading) { newHeading in
            previousHeading = compass.heading
        }
    }
}

struct CompassDot: View {
    let color: Color
    let rect: CGRect
    let padding: CGFloat
    let cornerRadius: CGFloat
    let angle: Double
    let previousAngle: Double
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .position(rect.pointOnRoundedRectEdge(angle: angle, padding: padding, cornerRadius: cornerRadius))
            .animation(.linear(duration: 0.15), value: angle)
    }
}

extension CGRect {
    func pointOnRoundedRectEdge(angle: Double, padding: CGFloat = 6, cornerRadius: CGFloat = 40) -> CGPoint {
        let rect = self.insetBy(dx: padding, dy: padding)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let width = rect.width
        let height = rect.height
        
        // Normalize angle to 0-360 degrees
        let normalizedAngle = (angle.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        
        // Calculate which edge the angle corresponds to
        // Top edge: 315-45 degrees
        // Right edge: 45-135 degrees  
        // Bottom edge: 135-225 degrees
        // Left edge: 225-315 degrees
        
        let x: CGFloat
        let y: CGFloat
        
        if normalizedAngle >= 315 || normalizedAngle < 45 {
            // Top edge
            let progress = normalizedAngle >= 315 ? (normalizedAngle - 315) / 90 : (normalizedAngle + 45) / 90
            let edgeProgress = max(0, min(1, progress))
            
            if edgeProgress <= cornerRadius / (width / 2) || edgeProgress >= 1 - cornerRadius / (width / 2) {
                // In corner region - calculate arc position
                let cornerAngle = edgeProgress <= cornerRadius / (width / 2) ? 
                    (edgeProgress * (width / 2) / cornerRadius) * .pi / 2 : 
                    ((1 - edgeProgress) * (width / 2) / cornerRadius) * .pi / 2
                
                if edgeProgress <= cornerRadius / (width / 2) {
                    // Top-left corner
                    x = rect.minX + cornerRadius - cornerRadius * cos(cornerAngle)
                    y = rect.minY + cornerRadius - cornerRadius * sin(cornerAngle)
                } else {
                    // Top-right corner
                    x = rect.maxX - cornerRadius + cornerRadius * sin(cornerAngle)
                    y = rect.minY + cornerRadius - cornerRadius * cos(cornerAngle)
                }
            } else {
                // Straight top edge
                let straightProgress = (edgeProgress - cornerRadius / (width / 2)) / (1 - 2 * cornerRadius / width)
                x = rect.minX + cornerRadius + (width - 2 * cornerRadius) * straightProgress
                y = rect.minY
            }
        } else if normalizedAngle >= 45 && normalizedAngle < 135 {
            // Right edge
            let progress = (normalizedAngle - 45) / 90
            let edgeProgress = max(0, min(1, progress))
            
            if edgeProgress <= cornerRadius / (height / 2) || edgeProgress >= 1 - cornerRadius / (height / 2) {
                // In corner region - calculate arc position
                let cornerAngle = edgeProgress <= cornerRadius / (height / 2) ? 
                    (edgeProgress * (height / 2) / cornerRadius) * .pi / 2 : 
                    ((1 - edgeProgress) * (height / 2) / cornerRadius) * .pi / 2
                
                if edgeProgress <= cornerRadius / (height / 2) {
                    // Top-right corner
                    x = rect.maxX - cornerRadius + cornerRadius * sin(cornerAngle)
                    y = rect.minY + cornerRadius - cornerRadius * cos(cornerAngle)
                } else {
                    // Bottom-right corner
                    x = rect.maxX - cornerRadius + cornerRadius * cos(cornerAngle)
                    y = rect.maxY - cornerRadius + cornerRadius * sin(cornerAngle)
                }
            } else {
                // Straight right edge
                let straightProgress = (edgeProgress - cornerRadius / (height / 2)) / (1 - 2 * cornerRadius / height)
                x = rect.maxX
                y = rect.minY + cornerRadius + (height - 2 * cornerRadius) * straightProgress
            }
        } else if normalizedAngle >= 135 && normalizedAngle < 225 {
            // Bottom edge
            let progress = (normalizedAngle - 135) / 90
            let edgeProgress = max(0, min(1, progress))
            
            if edgeProgress <= cornerRadius / (width / 2) || edgeProgress >= 1 - cornerRadius / (width / 2) {
                // In corner region - calculate arc position
                let cornerAngle = edgeProgress <= cornerRadius / (width / 2) ? 
                    (edgeProgress * (width / 2) / cornerRadius) * .pi / 2 : 
                    ((1 - edgeProgress) * (width / 2) / cornerRadius) * .pi / 2
                
                if edgeProgress <= cornerRadius / (width / 2) {
                    // Bottom-right corner
                    x = rect.maxX - cornerRadius + cornerRadius * cos(cornerAngle)
                    y = rect.maxY - cornerRadius + cornerRadius * sin(cornerAngle)
                } else {
                    // Bottom-left corner
                    x = rect.minX + cornerRadius - cornerRadius * sin(cornerAngle)
                    y = rect.maxY - cornerRadius + cornerRadius * cos(cornerAngle)
                }
            } else {
                // Straight bottom edge
                let straightProgress = (edgeProgress - cornerRadius / (width / 2)) / (1 - 2 * cornerRadius / width)
                x = rect.maxX - cornerRadius - (width - 2 * cornerRadius) * straightProgress
                y = rect.maxY
            }
        } else {
            // Left edge
            let progress = (normalizedAngle - 225) / 90
            let edgeProgress = max(0, min(1, progress))
            
            if edgeProgress <= cornerRadius / (height / 2) || edgeProgress >= 1 - cornerRadius / (height / 2) {
                // In corner region - calculate arc position
                let cornerAngle = edgeProgress <= cornerRadius / (height / 2) ? 
                    (edgeProgress * (height / 2) / cornerRadius) * .pi / 2 : 
                    ((1 - edgeProgress) * (height / 2) / cornerRadius) * .pi / 2
                
                if edgeProgress <= cornerRadius / (height / 2) {
                    // Bottom-left corner
                    x = rect.minX + cornerRadius - cornerRadius * sin(cornerAngle)
                    y = rect.maxY - cornerRadius + cornerRadius * cos(cornerAngle)
                } else {
                    // Top-left corner
                    x = rect.minX + cornerRadius - cornerRadius * cos(cornerAngle)
                    y = rect.minY + cornerRadius - cornerRadius * sin(cornerAngle)
                }
            } else {
                // Straight left edge
                let straightProgress = (edgeProgress - cornerRadius / (height / 2)) / (1 - 2 * cornerRadius / height)
                x = rect.minX
                y = rect.maxY - cornerRadius - (height - 2 * cornerRadius) * straightProgress
            }
        }
        
        return CGPoint(x: x, y: y)
    }
}
