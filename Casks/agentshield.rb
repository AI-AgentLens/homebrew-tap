cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1947"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1947/agentshield_0.2.1947_darwin_amd64.tar.gz"
      sha256 "6ef61d002dbe7054cc335d9187cf1d6028aeb1daf40515bd6ce14c9daadad333"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1947/agentshield_0.2.1947_darwin_arm64.tar.gz"
      sha256 "f64d2c7e771dbef6b11187b3f31c2a2fd0d434bb3d7ed478e747cbe584d705d1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1947/agentshield_0.2.1947_linux_amd64.tar.gz"
      sha256 "fa7debf49be23dc3cd27ae48513360c32d2236563d41391a02b4f727317a4198"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1947/agentshield_0.2.1947_linux_arm64.tar.gz"
      sha256 "14b59a27c9c0ce0cd67558dcaecbff73fbe798c75b6183424c9961510a7412fe"
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
