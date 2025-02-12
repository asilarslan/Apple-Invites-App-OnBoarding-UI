//
//  InfiniteScrollView.swift
//  Invites OnBoarding
//
//  Created by Asil Arslan on 12.02.2025.
//

import SwiftUI

struct InfiniteScrollView<Content: View>:View {
    var spacing: CGFloat = 10
    @ViewBuilder var content: Content
    @State private var contentSize: CGSize = .zero
    var body: some View{
        GeometryReader{
            let size = $0.size
            ScrollView(.horizontal){
                HStack(spacing: spacing){
                    Group(subviews: content){ collection in
                        HStack(spacing: spacing){
                            ForEach(collection) { view in
                                view
                            }
                        }
                        .onGeometryChange(for: CGSize.self){
                            $0.size
                        } action: { newValue in
                            contentSize = .init(width: newValue.width + spacing, height: newValue.height)
                        }
                        
                        
                        let averageWidth = contentSize.width / CGFloat(collection.count)
                        let repeatingCount = contentSize.width > 0 ? Int((size.width / averageWidth).rounded()) + 1 : 1
                        
                        HStack(spacing: spacing){
                            ForEach(0..<repeatingCount, id: \.self) { index in
                                let view = Array(collection)[index % collection.count]
                                view
                            }
                            .background(InfiniteScrollHelper(contentSize: $contentSize, declarationRate: .constant(.fast)))
                            
                        }
                    }
                }
            }
        }
    }
    
    fileprivate struct InfiniteScrollHelper: UIViewRepresentable {
        @Binding var contentSize: CGSize
        @Binding var declarationRate: UIScrollView.DecelerationRate
        
        func makeCoordinator() -> Coordinator {
            Coordinator(declarationRate: declarationRate, contentSize: contentSize)
        }
        
        func makeUIView(context: Context) -> UIView {
            let view = UIView(frame: .zero)
            view.backgroundColor = .clear
            
            DispatchQueue.main.async {
                if let scrollView = view.scrollView {
                    context.coordinator.defaultDelegate = scrollView.delegate
                    scrollView.decelerationRate = declarationRate
                    scrollView.delegate = context.coordinator
                }
            }
            return view
        }
        
        func updateUIView(_ uiView:UIView, context: Context){
            context.coordinator.declarationRate = declarationRate
            
            context.coordinator.contentSize = contentSize
        }
        
        class Coordinator: NSObject, UIScrollViewDelegate {
            var declarationRate: UIScrollView.DecelerationRate
            var contentSize: CGSize
            
            init(declarationRate: UIScrollView.DecelerationRate, contentSize: CGSize){
                self.declarationRate = declarationRate
                self.contentSize = contentSize
            }
            
            weak var defaultDelegate: UIScrollViewDelegate?
            
            func scrollViewDidScroll(_ scrollView: UIScrollView) {
                scrollView.decelerationRate = declarationRate
                
                let minX = scrollView.contentOffset.x
                if minX > contentSize.width {
                    scrollView.contentOffset.x -= contentSize.width
                }
                
                if minX < 0 {
                    scrollView.contentOffset.x += contentSize.width
                }
                
                defaultDelegate?.scrollViewDidScroll?(scrollView)
            }
            
            
            func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool){
                defaultDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
            }
            
            func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
                defaultDelegate?.scrollViewDidEndDecelerating?(scrollView)
            }
            
            func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
                defaultDelegate?.scrollViewWillBeginDragging?(scrollView)
            }
            
            func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
                defaultDelegate?.scrollViewWillEndDragging?(
                    scrollView,
                    withVelocity: velocity,
                    targetContentOffset: targetContentOffset
                )
            }
        }
        
    }
    
}

extension View{
    func blurOpacityEffect(_ show: Bool) -> some View {
        self
            .blur(radius: show ? 0:2)
            .opacity(show ? 1:0)
            .scaleEffect(show ? 1:0.9)
    }
}

