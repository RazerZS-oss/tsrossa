import SwiftUI
import AppKit

public struct LyricsView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    public var isTheater: Bool = false
    
    public init(isTheater: Bool = false) {
        self.isTheater = isTheater
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    if vm.isLoadingLyrics {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(isTheater ? 0.9 : 0.8)
                            Text("Loading lyrics...")
                                .font(.system(size: isTheater ? 13 : 12, design: .monospaced))
                                .foregroundColor(vm.currentTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 320)
                    } else if vm.currentLyrics.isEmpty {
                        VStack(spacing: 14) {
                            Image(systemName: "quote.bubble")
                                .font(.system(size: isTheater ? 48 : 40))
                                .foregroundColor(vm.currentTheme.textMuted)
                            Text("No Lyrics Available")
                                .font(.system(size: isTheater ? 20 : 18, weight: .bold))
                                .foregroundColor(vm.currentTheme.textPrimary)
                            Text("Place a .lrc or .txt companion file in the same folder as your audio file:\n\(engine.currentTrack?.title ?? "song").lrc")
                                .font(.system(size: isTheater ? 13 : 12))
                                .foregroundColor(vm.currentTheme.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            if isTheater {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        vm.theaterTabMode = "QUEUE"
                                    }
                                }) {
                                    Text("View Up Next Queue →")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(vm.currentTheme.onPrimary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(vm.currentTheme.primary)
                                        .cornerRadius(14)
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else if let cur = engine.currentTrack {
                                Button(action: {
                                    NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: cur.path)])
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "folder")
                                        Text("Open Track Folder in Finder")
                                    }
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(vm.currentTheme.onPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(vm.currentTheme.primary)
                                    .cornerRadius(14)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(40)
                        .frame(maxWidth: .infinity, minHeight: 320)
                    } else {
                        VStack(alignment: .leading, spacing: isTheater ? 22 : 18) {
                            ForEach(Array(vm.currentLyrics.enumerated()), id: \.element.id) { idx, line in
                                let isCurrent = (idx == vm.currentLyricIndex)
                                Button(action: {
                                    if line.isSynced {
                                        engine.seek(to: line.timestampSeconds)
                                    }
                                }) {
                                    HStack(alignment: .top, spacing: isTheater ? 16 : 14) {
                                        if line.isSynced {
                                            Text(vm.formatTime(line.timestampSeconds))
                                                .font(.system(size: isTheater ? 12 : 11, weight: .semibold, design: .monospaced))
                                                .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textMuted.opacity(0.55))
                                                .frame(width: isTheater ? 48 : 44, alignment: .leading)
                                                .padding(.top, 2)
                                        }
                                        
                                        Text(line.text)
                                            .font(.system(size: isCurrent ? (isTheater ? 24 : 22) : (isTheater ? 17 : 16), weight: isCurrent ? .bold : .medium))
                                            .foregroundColor(isCurrent ? vm.currentTheme.textPrimary : vm.currentTheme.textMuted)
                                            .lineSpacing(isTheater ? 5 : 4)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, isTheater ? 10 : 8)
                                    .background(isCurrent ? vm.currentTheme.primaryContainer.opacity(0.35) : Color.clear)
                                    .cornerRadius(12)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .id(idx)
                            }
                        }
                        .padding(.horizontal, isTheater ? 16 : 36)
                        .padding(.vertical, 28)
                    }
                }
            }
            .onChange(of: vm.currentLyricIndex) { newIndex in
                if newIndex >= 0 {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
        }
        .if(isTheater) { view in
            view
                .background(Color.white.opacity(0.03))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        }
    }
}

private extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
