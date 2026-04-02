cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.331"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.331/agentshield_0.2.331_darwin_amd64.tar.gz"
      sha256 "791306ce6f15d7d7d8cebf665c318b2990a2a29e095b36b6bfbcdbcbb07b466c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.331/agentshield_0.2.331_darwin_arm64.tar.gz"
      sha256 "f64da9507c3999dbccf271a646a5f082a0174f3cc985f7ac4b4dff9e535102f1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.331/agentshield_0.2.331_linux_amd64.tar.gz"
      sha256 "ed4fb7d693fc4798e66fbaad64fbf75348c2be7159306fe7b730b4eaa55e835d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.331/agentshield_0.2.331_linux_arm64.tar.gz"
      sha256 "2bebeabeb10e3a21dd4a27e5685393ab10e1f94b4a9cc1dc1118056170f0586b"
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
