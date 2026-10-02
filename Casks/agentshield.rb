cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2319"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2319/agentshield_0.2.2319_darwin_amd64.tar.gz"
      sha256 "ade58d67f22bb991794ea2ca9fdf5fdbb67f8d763e1c16132f4cc3f1efc27b38"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2319/agentshield_0.2.2319_darwin_arm64.tar.gz"
      sha256 "b6b3c6b277523d7f79aa7089032317e461b6543e7144c4a381a378ee7a6b68e2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2319/agentshield_0.2.2319_linux_amd64.tar.gz"
      sha256 "a29bb06bf622dc8c59e554d2576dc1acaed00e9b6746426f341eddfa875fd2ea"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2319/agentshield_0.2.2319_linux_arm64.tar.gz"
      sha256 "4651e509805337b1e9cd71c701b789445a77205e997063ca926d229c9508dca9"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
