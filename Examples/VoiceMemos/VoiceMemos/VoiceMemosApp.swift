import ComposableArchitecture
import Foundation
import SwiftUI

@main
struct VoiceMemosApp: App {
  var body: some Scene {
    WindowGroup {
      VoiceMemosView(
        store: Store(
          initialState: VoiceMemosState(),
          reducer:
            voiceMemosReducer
            .debug(),
          environment: VoiceMemosEnvironment(
            audioPlayer: .live,
            audioRecorder: .live,
            mainRunLoop: .main,
            openSettings: {
              await MainActor.run {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
              }
            },
            temporaryDirectory: { URL(fileURLWithPath: NSTemporaryDirectory()) },
            uuid: { UUID() }
          )
        )
      )
    }
  }
}
