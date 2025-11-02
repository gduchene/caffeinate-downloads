import ArgumentParser
import Foundation
import Logging
import ServiceLifecycle
import SystemPackage

@main
struct EntryPoint: AsyncParsableCommand {
  @Option(help: "Directory to search for ongoing downloads.", transform: { FilePath($0) })
  var directory = FilePath("\(NSHomeDirectory())/Downloads")

  @Option(help: "Suffix of ongoing downloads.")
  var suffix = "part"

  @Flag(help: "Enable verbose output.")
  var verbose = false

  func run() async throws {
    var logger = Logger(label: "caffeinate-downloads")
    if self.verbose {
      logger.logLevel = .debug
    }

    try await ServiceGroup(
      services: [Watcher(directory: self.directory, logger: logger, suffix: self.suffix)],
      cancellationSignals: [.sigint, .sigquit],
      logger: logger
    ).run()
  }
}
