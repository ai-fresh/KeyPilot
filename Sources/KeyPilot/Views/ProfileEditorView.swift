import SwiftUI

struct ProfileEditorView: View {
    @Bindable var profileStore: ProfileStore
    var profileSwitcher: ProfileSwitcher
    @State private var selectedProfileID: UUID?
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationSplitView {
            List(profileStore.profiles, selection: $selectedProfileID) { profile in
                HStack {
                    Text(profile.icon)
                    Text(profile.name)
                    Spacer()
                    if profile.isDefault {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                    }
                    if profile.id == profileSwitcher.activeProfile?.id {
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                            .help("Currently active")
                    }
                }
                .tag(profile.id)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 220)
            .toolbar {
                ToolbarItemGroup {
                    Button(action: addProfile) {
                        Label("Add", systemImage: "plus")
                    }
                    Button(action: { showDeleteConfirmation = true }) {
                        Label("Delete", systemImage: "minus")
                    }
                    .disabled(selectedProfileID == nil)
                }
            }
            .confirmationDialog(
                "Delete this profile?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteSelected()
                }
            }
        } detail: {
            if let selectedID = selectedProfileID,
                let profile = profileStore.profiles.first(where: { $0.id == selectedID })
            {
                ProfileFormView(
                    profile: profile,
                    isUploading: profileSwitcher.isUploading,
                    uploadError: profileSwitcher.lastUploadError,
                    onSave: { updated in
                        let oldDefault = profileStore.defaultProfile()?.id

                        // If this profile is being set as default, unset others
                        if updated.isDefault {
                            profileStore.setAsDefault(updated)
                        }
                        profileStore.update(updated)

                        // If default changed, notify switcher
                        if updated.isDefault && oldDefault != updated.id {
                            profileSwitcher.onDefaultProfileChanged()
                        }

                        // Upload to device
                        Task {
                            await profileSwitcher.uploadOnSave(profile: updated)
                        }
                    }
                )
                .id(selectedID)
            } else {
                ContentUnavailableView(
                    "Select a Profile",
                    systemImage: "keyboard",
                    description: Text("Choose a profile from the sidebar or create a new one.")
                )
            }
        }
    }

    private func addProfile() {
        let newProfile = Profile(
            name: "New Profile",
            icon: "🎯",
            keyMapping: KeyMapping(
                button1: "f13", button2: "f14", button3: "f15",
                knobCCW: "volumedown", knobPress: "mute", knobCW: "volumeup"
            )
        )
        profileStore.add(newProfile)
        selectedProfileID = newProfile.id
    }

    private func deleteSelected() {
        guard let id = selectedProfileID,
            let profile = profileStore.profiles.first(where: { $0.id == id })
        else { return }
        profileStore.delete(profile)
        selectedProfileID = profileStore.profiles.first?.id
    }
}
