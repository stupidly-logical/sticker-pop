import SwiftUI

/// Tags typed into a field: removable chips inside a text-field box, then an
/// inline text field. Return or a comma adds what was typed; duplicates
/// (ignoring case) are skipped.
public struct PopTagInput: View {
    @Binding var tags: [String]
    var hint: String
    var label: String?
    @State private var text = ""
    @FocusState private var focused: Bool

    public init(tags: Binding<[String]>, hint: String = "Add a tag", label: String? = nil) {
        self._tags = tags
        self.hint = hint
        self.label = label
    }

    private func add(_ raw: String) {
        let t = raw.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespaces)
        text = ""
        guard !t.isEmpty, !tags.contains(where: { $0.caseInsensitiveCompare(t) == .orderedSame }) else { return }
        tags.append(t)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let label { PopText(label, PopTextSpecs.fieldLabel) }
            PopWrap(spacing: PopSpace.sm, runSpacing: PopSpace.sm) {
                ForEach(tags, id: \.self) { t in
                    PopChip(t, selected: false, onRemove: { tags.removeAll { $0 == t } }) {}
                }
                TextField("", text: $text, prompt: tags.isEmpty ? Text(hint).foregroundColor(PopColors.inkMuted) : nil)
                    .font(.pop(PopTextSpecs.input.size, weight: PopTextSpecs.input.weight))
                    .foregroundStyle(PopColors.ink)
                    .tint(PopColors.ink)
                    .focused($focused)
                    .submitLabel(.done)
                    .onSubmit { add(text); focused = true }
                    .onChange(of: text) { v in if v.contains(",") { add(v) } }
                    .frame(minWidth: 120)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
            }
            .padding(.horizontal, PopSpace.sm)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, minHeight: PopSize.tapTarget, alignment: .leading)
            .sticker(fill: PopColors.white, radius: PopRadius.field, border: focused ? PopBorder.regular : PopBorder.thin, shadow: 0)
            .contentShape(Rectangle())
            .onTapGesture { focused = true }
        }
    }
}
