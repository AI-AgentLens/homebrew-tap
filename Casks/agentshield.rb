cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.517"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.517/agentshield_0.2.517_darwin_amd64.tar.gz"
      sha256 "6f95ae2888e168b76848ee7e28d5c2cfd9cb10d749279fcf93e30a345d731880"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.517/agentshield_0.2.517_darwin_arm64.tar.gz"
      sha256 "f017e9d00972786dc25348a656968cb0558c177bd66f73968de7378d1bd9677f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.517/agentshield_0.2.517_linux_amd64.tar.gz"
      sha256 "ec81bf9fb278094afcffe81957b5c19a773d4a9d25d343730cc4b94734cfcdfc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.517/agentshield_0.2.517_linux_arm64.tar.gz"
      sha256 "b3fe29e1cf39e12ec39df536e96ddddbcab71a983c3f982b11e6416fce11f470"
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
