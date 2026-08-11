cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1814"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1814/agentshield_0.2.1814_darwin_amd64.tar.gz"
      sha256 "22dd4dc8bd889164d1d0b9c527ad4846da814d0e0e5077a85d01f7d99f1a8491"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1814/agentshield_0.2.1814_darwin_arm64.tar.gz"
      sha256 "3312ed0ed854ffab19df70fde557f8601de6837e038ae3a7c47c1bee599a2745"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1814/agentshield_0.2.1814_linux_amd64.tar.gz"
      sha256 "88f44562159f421efaf100ba9c37f2beb08eda3891f6fa3ed34a3808ef90f877"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1814/agentshield_0.2.1814_linux_arm64.tar.gz"
      sha256 "64848083546d8070391cff72d305495824a93cbb4630fcca8268a7e9f75e1a8c"
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
