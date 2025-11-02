import Logging
import ServiceLifecycle
import SystemPackage
import _NIOFileSystem

struct Watcher: Service {
  let directory: FilePath
  let logger: Logger
  let suffix: String

  func run() async {
    let sleepInhibitor = SleepInhibitor()

    while !Task.isCancelled {
      let isDownloading: Bool
      do {
        isDownloading = try await FileSystem.shared.withDirectoryHandle(atPath: self.directory) {
          try await $0.listContents().contains {
            $0.name.extension?.hasSuffix(self.suffix) ?? false
          }
        }
      } catch is CancellationError {
        return
      } catch {
        self.logger.error("Failed to check directory: \(error)")
        return
      }

      switch (isDownloading, await sleepInhibitor.isInhibitingSleep) {
      case (true, false):
        self.logger.debug("Ongoing downloads found, inhibiting sleep")
        do {
          try await sleepInhibitor.create(
            name: "caffeinate-downloads",
            details: "There are files being downloaded"
          )
        } catch {
          self.logger.error("Failed to create assertion: \(error)")
        }

      case (false, true):
        self.logger.debug("No ongoing downloads found, allowing sleep")
        do {
          try await sleepInhibitor.release()
        } catch {
          self.logger.error("Failed to release assertion: \(error)")
        }

      default:
        break
      }

      guard (try? await Task.sleep(for: .seconds(30))) != nil else {
        return
      }
    }
  }
}
