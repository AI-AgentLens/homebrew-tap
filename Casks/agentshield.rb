cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1207"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1207/agentshield_0.2.1207_darwin_amd64.tar.gz"
      sha256 "0f5fa4ab2e19e63b058596081f57f5fe1c0d8cea59ce116d6faba9795afa3d8e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1207/agentshield_0.2.1207_darwin_arm64.tar.gz"
      sha256 "62669520bfe2e700e9a66ae47b4da4f208964e5ab63f1d6cfdd4b1a120e4b53b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1207/agentshield_0.2.1207_linux_amd64.tar.gz"
      sha256 "b6bc79659df128261b09acd0917c82995d88132709113fbc6c5393ea9d6b6614"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1207/agentshield_0.2.1207_linux_arm64.tar.gz"
      sha256 "7b0ed7f60ca97367cc272d4421c5c1d9b08a7857d4f484ca69cefe4f5125511f"
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
