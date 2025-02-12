//
//  TitleTextRenderer.swift
//  Invites OnBoarding
//
//  Created by Asil Arslan on 12.02.2025.
//

import SwiftUI

struct TitleTextRenderer: TextRenderer, Animatable {
    var progress: CGFloat
    var animatableData: CGFloat{
        get{ progress }
        set{ progress = newValue }
    }
    
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext){
        let slices = layout.flatMap({$0}).flatMap({$0})
        
        for(index,slice) in slices.enumerated() {
            let sliceProgressIndex = CGFloat(slices.count) * progress
            let sliceProgress = max(min(sliceProgressIndex / CGFloat(index + 1), 1 ), 0)
            
            ctx.addFilter(.blur(radius: 5 - (5 * sliceProgress)))
            ctx.opacity = sliceProgress
            ctx.translateBy(x: 0, y: 5 - ( 5 * sliceProgress))
            ctx.draw(slice, options: .disablesSubpixelQuantization)
            
        }
        
    }
    
}

