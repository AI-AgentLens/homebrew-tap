cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2197"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2197/agentshield_0.2.2197_darwin_amd64.tar.gz"
      sha256 "bef713a8b3b60f223f96e15f1ae83582f604fd40be7bdc0037cd75c9bd932d0d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2197/agentshield_0.2.2197_darwin_arm64.tar.gz"
      sha256 "657a88774d530be96f2490d4fb372015f5e58b0a342835820957ebf87387334c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2197/agentshield_0.2.2197_linux_amd64.tar.gz"
      sha256 "1c09e19b4268ba21cbcec964ccdf53e7dc92f253daf2aceef9b5bf1873d57ad2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2197/agentshield_0.2.2197_linux_arm64.tar.gz"
      sha256 "6794bce15793b3d1fae80d0017db34ec87fbbb2fac0170df648217a0950c09be"
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
