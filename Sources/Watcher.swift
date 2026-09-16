import Logging
import ServiceLifecycle
import _NIOFileSystem

struct Watcher: Service {
  let directory: FilePath
  let logger: Logger
  let suffix: String

  func foundDownloads() async throws -> Bool {
    try await FileSystem.shared.withDirectoryHandle(atPath: self.directory) {
      try await $0.listContents().contains {
        $0.name.string.hasSuffix(self.suffix)
      }
    }
  }

  func run() async throws {
    while !Task.isCancelled {
      do {
        while try await !foundDownloads() {
          try await Task.sleep(for: .seconds(30))
        }

        try await withSleepInhibited {
            self.logger.debug("Ongoing downloads found, inhibiting sleep")
            while try await foundDownloads() {
                try await Task.sleep(for: .seconds(30))
            }
            self.logger.debug("No ongoing downloads found, allowing sleep")
        }
      } catch is CancellationError {
        return
      }
    }
  }
}
