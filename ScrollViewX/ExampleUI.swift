import SwiftUI

struct ExampleUI: View {
    
    @State private var rectangles: [Color] = []
    @State private var status: String = ""
    
    var body: some View {
        VStack {
            Text(status)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.purple)
                .padding()
            ScrollViewX(
                actionHandler: { action in
                    switch action {
                    case .didEndDecelerating:
                        status = "didEndDecelerating"
                    case .didEndDragging:
                        status = "didEndDragging"
                    case .didScroll:
                        status = "didScroll"
                    }
                }) {
                    VStack(spacing: 10) {
                        ForEach(rectangles, id: \.self) { color in
                            Rectangle()
                                .fill(color)
                                .frame(width: UIScreen.main.bounds.width - 40, height: 100)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 10)
                }
            Button(action: addRectangle) {
                Text("Add More")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
    }
    
    private func addRectangle() {
        let newColor = Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
        rectangles.append(newColor)
    }
    
}
