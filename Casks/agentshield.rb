cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.787"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.787/agentshield_0.2.787_darwin_amd64.tar.gz"
      sha256 "cb0c92a7bacbb025f2bb8f63e4c89387c7fb04842471a688b75f49ffb48aac90"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.787/agentshield_0.2.787_darwin_arm64.tar.gz"
      sha256 "0d2f7b8fb83b398e3ceaa2f4f38ecbd191393dae3bd9c0b6ecfd9f66c74f018e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.787/agentshield_0.2.787_linux_amd64.tar.gz"
      sha256 "124434dea998f832ea852dae3f0b1de99aa01fd0dd18ae1d2f3dee2412e8fbe7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.787/agentshield_0.2.787_linux_arm64.tar.gz"
      sha256 "472b7d9d2ad43853ef9558b180e5d0e91b9c2976d83deb9bae43fa5b0ee4987f"
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
