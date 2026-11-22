import SwiftUI

private let avatarFills = [PopColors.yellow, PopColors.pink, PopColors.blue, PopColors.mint, PopColors.lilac, PopColors.orange]

/// Up to two initials: the first letters of the first and last words.
public func popInitials(_ name: String) -> String {
    let words = name.split(whereSeparator: { $0.isWhitespace })
    guard let first = words.first?.first else { return "?" }
    let last = words.count > 1 ? String(words.last!.first!) : ""
    return (String(first) + last).uppercased()
}

/// The bright a name always gets, the same on every platform: the sum of
/// its UTF-16 code units, modulo six.
public func popAvatarColor(_ name: String) -> Color {
    let sum = name.trimmingCharacters(in: .whitespacesAndNewlines).utf16.reduce(0) { $0 + Int($1) }
    return avatarFills[sum % avatarFills.count]
}

/// A person, payee or shared account: their initials in a bright circle with
/// a 2 ink outline, coloured from the name. Sizes: 32, 42 (default), 56.
public struct PopAvatar: View {
    let name: String
    var size: CGFloat
    var color: Color?

    public init(_ name: String, size: CGFloat = 42, color: Color? = nil) {
        self.name = name
        self.size = size
        self.color = color
    }

    public var body: some View {
        Text(popInitials(name))
            .font(.custom("Bricolage Grotesque", fixedSize: size * 0.38).weight(.heavy))
            .foregroundStyle(PopColors.ink)
            .frame(width: size, height: size)
            .background(Circle().fill(color ?? popAvatarColor(name)))
            .overlay(Circle().strokeBorder(PopColors.ink, lineWidth: PopBorder.thin))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(name)
            .accessibilityAddTraits(.isImage)
    }
}
