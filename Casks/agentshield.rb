cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2067"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2067/agentshield_0.2.2067_darwin_amd64.tar.gz"
      sha256 "c1d26b15e6f271155d20f37a903957baad7e98a66f25ececf351a6b18a73680a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2067/agentshield_0.2.2067_darwin_arm64.tar.gz"
      sha256 "6b8a62106fae2fa8e6aec92c2663b97e8fb81f79ac661e7de4096d3635b50e69"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2067/agentshield_0.2.2067_linux_amd64.tar.gz"
      sha256 "09e87bd0ba5a3412f478c9bb50b5a44a1ec806e332ecbf03165e320797f68b0f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2067/agentshield_0.2.2067_linux_arm64.tar.gz"
      sha256 "9f2d1119b8d548516af88ac7b0c5b1d05c8f62a30082fc5f26b750fba5cb5dce"
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
