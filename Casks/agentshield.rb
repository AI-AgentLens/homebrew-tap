cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.843"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.843/agentshield_0.2.843_darwin_amd64.tar.gz"
      sha256 "518302186f9464912052a99c2b0949942146641bd5ac893ce3c0be20f5c16eb0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.843/agentshield_0.2.843_darwin_arm64.tar.gz"
      sha256 "f12cdd6fd196937ec6ee8fe47ce17200d4e8b08a1bed09bf93bc3a155818e6e7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.843/agentshield_0.2.843_linux_amd64.tar.gz"
      sha256 "7d1a1f761ffb4d0e0a4b980838f3475f75a667fd36757e48fa8845966b7b9e35"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.843/agentshield_0.2.843_linux_arm64.tar.gz"
      sha256 "88af3a37790d31720ceab5a13a36df00242465ef96ed0882bb986903080cddcd"
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
