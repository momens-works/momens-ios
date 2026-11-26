import SwiftUI

struct TaskEditDragHandle: View{
    let onDragStart: ()-> Void
    let onDragChanged: (CGSize) -> Void
    let onDragEnded : ()-> Void
    
    @GestureState private var isDragging = false
    
    @State private var hasActiveDrag = false
    
    var body: some View{
        RoundedRectangle(cornerRadius: 6)
            .fill(MomensColor.gray200)
            .frame(width:2)
            .frame(maxHeight: .infinity)
            .padding(.vertical,3)
            .frame(width : 24)
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .onChange(of: isDragging) { _, isDragging in
                    if !isDragging{
                        finishDrag()
                    }
                }
                .onDisappear(){
                    finishDrag()
                }
                                    
    }
    
    private var dragGesture: some Gesture{
        DragGesture(
            minimumDistance: 5,
            coordinateSpace: .global
        )
        .updating($isDragging) {_, state, _ in state = true}
        .onChanged{ value in if !hasActiveDrag{
            hasActiveDrag = true
            onDragStart()
        }
            
            onDragChanged(value.translation)
                
            }
        .onEnded{
            value in onDragChanged(value.translation)
            finishDrag()
        }
    }
    
    private func finishDrag(){
        guard hasActiveDrag else {return }
        
        hasActiveDrag = false
        onDragEnded()
    }
}
