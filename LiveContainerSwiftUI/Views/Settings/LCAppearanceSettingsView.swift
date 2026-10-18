import SwiftUI

struct LCAppearanceSettingsView: View {
    private var appearance = LCAppearance()
    @AppStorage("dynamicColors", store: LCUtils.appGroupUserDefault) private var dynamicColors = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Form {
            Section {
                Picker("lc.appearance.cardStyle".loc, selection: appearance.$pastelCards) {
                    Text("lc.appearance.current".loc).tag(false)
                    Text("lc.appearance.pastel".loc).tag(true)
                }
                .pickerStyle(.segmented)

                if !appearance.pastelCards {
                    Toggle("lc.settings.dynamicColors".loc, isOn: $dynamicColors)
                }
            } header: {
                Text("lc.appearance.cardStyle".loc)
            } footer: {
                Text(appearance.pastelCards ? "lc.appearance.paletteDescription".loc : "lc.settings.dynamicColors.desc".loc)
            }

            if appearance.pastelCards {
                Section {
                    ForEach(LCAppearance.presets.indices, id: \.self) { index in
                        presetButton(at: index)
                    }
                } header: {
                    Text("lc.appearance.presets".loc)
                }

                Section {
                    ForEach(0..<4, id: \.self) { index in
                        ColorPicker("lc.appearance.color %lld".localizeWithFormat(index + 1), selection: Binding(
                            get: { Color(uiColor: appearance.palette[index].uiColor) },
                            set: { appearance.setPaletteColor($0, at: index) }
                        ), supportsOpacity: false)
                    }
                    Button("lc.appearance.resetPalette".loc) {
                        appearance.paletteStorage = LCAppearance.defaultPalette
                    }
                } header: {
                    Text("lc.appearance.palette".loc)
                }

                Section {
                    preview
                        .listRowInsets(EdgeInsets())
                } header: {
                    Text("lc.appearance.preview".loc)
                }
            }

            Section {
                Toggle("lc.appearance.customBackground".loc, isOn: appearance.$customBackground)
                if appearance.customBackground {
                    ColorPicker("lc.appearance.backgroundColor".loc, selection: Binding(
                        get: { Color(uiColor: appearance.background.uiColor) },
                        set: { appearance.backgroundStorage = LCThemeColor(color: $0).hex }
                    ), supportsOpacity: false)
                    Button("lc.appearance.resetBackground".loc) {
                        appearance.customBackground = false
                        appearance.backgroundStorage = "#FFF7FB"
                    }
                }
            } header: {
                Text("lc.appearance.background".loc)
            } footer: {
                Text("lc.appearance.backgroundDescription".loc)
            }
        }
        .meowBackground()
        .navigationTitle("lc.appearance.title".loc)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func presetButton(at index: Int) -> some View {
        let preset = LCAppearance.presets[index]
        return Button {
            appearance.paletteStorage = preset.colors
        } label: {
            HStack {
                Text(preset.name.loc)
                    .foregroundStyle(.primary)
                Spacer()
                ForEach(preset.colors.split(separator: ",").map(String.init), id: \.self) { hex in
                    Circle()
                        .fill(Color(uiColor: LCThemeColor(hex: hex)!.uiColor))
                        .frame(width: 20, height: 20)
                        .overlay(Circle().strokeBorder(Color.primary.opacity(0.15)))
                        .accessibilityHidden(true)
                }
                Image(systemName: appearance.paletteStorage == preset.colors ? "checkmark.circle.fill" : "circle")
            }
            .contentShape(Rectangle())
        }
        .accessibilityAddTraits(appearance.paletteStorage == preset.colors ? .isSelected : [])
    }

    private var preview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Meow Apps~")
                .font(.headline)
            ForEach(0..<4, id: \.self) { index in
                let colors = LCPastelCardColors(color: appearance.palette[index], isDark: colorScheme == .dark)
                HStack {
                    Image(systemName: "app.fill")
                        .font(.title2)
                        .accessibilityHidden(true)
                    Text("lc.appearance.previewApp %lld".localizeWithFormat(index + 1))
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("lc.appBanner.run".loc)
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .foregroundStyle(Color(uiColor: colors.buttonText))
                        .background(Capsule().fill(Color(uiColor: colors.button)))
                }
                .padding(12)
                .foregroundStyle(Color(uiColor: colors.text))
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(uiColor: colors.background)))
            }
        }
        .padding()
        .background(appearance.customBackground ? Color(uiColor: appearance.background.uiColor) : Color(uiColor: .systemBackground))
    }
}
