import SwiftUI
import Supabase

struct UserDeviceView: View {
    @StateObject private var viewModel: UserDeviceViewModel
    
    init(supabase: SupabaseClient, userId: UUID) {
        _viewModel = StateObject(wrappedValue: UserDeviceViewModel(supabase: supabase, userId: userId))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.devices) { device in
                DeviceRow(device: device)
                    .swipeActions {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.removeDevice(device)
                            }
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("Devices")
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred" as String)
        }
        .task {
            await viewModel.loadDevices()
        }
    }
}

struct DeviceRow: View {
    let device: UserDevice
    
    var body: some View {
        HStack(spacing: AdaptiveLayout.minimumSpacing) {
            Image(systemName: platformIcon)
                .font(.adaptiveTitle())
                .foregroundStyle(platformColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.adaptiveHeadline())
                
                Text("\(device.platform.rawValue) • \(device.osVersion)")
                    .font(.adaptiveSubheadline())
                    .foregroundStyle(.secondary)
                
                Text("Last active \(formatDate(device.lastActive))")
                    .font(.adaptiveSubheadline())
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if isCurrentDevice {
                Text("Current")
                    .font(.adaptiveCaption())
                    .foregroundStyle(.white)
                    .adaptivePadding(.horizontal, 8)
                    .adaptivePadding(.vertical, 4)
                    .background(Color.green)
                    .adaptiveCornerRadius(12)
            }
        }
        .adaptivePadding(.vertical, 4)
    }
    
    private var platformIcon: String {
        switch device.platform {
        case .iOS: return "iphone"
        case .web: return "globe"
        }
    }
    
    private var platformColor: Color {
        switch device.platform {
        case .iOS: return .blue
        case .web: return .green
        }
    }
    
    private var isCurrentDevice: Bool {
        device.platform == .iOS
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NavigationView {
        UserDeviceView(
            supabase: Config.supabaseClient,
            userId: UUID()
        )
    }
}
