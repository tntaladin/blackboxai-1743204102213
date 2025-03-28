import SwiftUI

struct LocationSearchActivationView: View {
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.black)
                .frame(width: 8, height: 8)
                .padding(.horizontal)
            
            Text("Where to?")
                .foregroundColor(Color(.darkGray))
            
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width - 64, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 0)
        )
    }
}

struct LocationSearchActivationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchActivationView()
    }
}