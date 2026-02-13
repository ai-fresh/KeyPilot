import SwiftUI

struct KeyMappingField: View {
    let label: String
    @Binding var value: String

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 140, alignment: .leading)
                .foregroundStyle(.secondary)

            TextField("np. cmd-c, f13, play", text: $value)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            if !value.isEmpty {
                if KeyMapping.isValidMapping(value) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .help("Unknown key mapping. Check spelling.")
                }
            }
        }
    }
}
