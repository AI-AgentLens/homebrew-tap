cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2003"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2003/agentshield_0.2.2003_darwin_amd64.tar.gz"
      sha256 "704767c473ac1641ef223e5dc659faa3950eb5f688007b739dba8467d627d887"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2003/agentshield_0.2.2003_darwin_arm64.tar.gz"
      sha256 "7f1325d647e354f527489dbd4db8466472bd16d78e246fcdca7dfa8d5e29a075"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2003/agentshield_0.2.2003_linux_amd64.tar.gz"
      sha256 "19c123b217913a2c41cc6e326b7f820558e3e70521546f55b22fa1c81fb315db"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2003/agentshield_0.2.2003_linux_arm64.tar.gz"
      sha256 "e0aa1652ce2b8c586b15e9017a21a35c12bf6d46f88d263bef0f18e48788cb2d"
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
