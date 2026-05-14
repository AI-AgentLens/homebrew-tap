cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.980"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.980/agentshield_0.2.980_darwin_amd64.tar.gz"
      sha256 "a82c03e938c9a8863f59a9e53b2049d73e5658506f02b02b00ce6b3c5595c6c9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.980/agentshield_0.2.980_darwin_arm64.tar.gz"
      sha256 "9aa7be839cb7ebed3e8d7fda082ed43aa89bc7ff15146443b4bda2ce7db0a68c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.980/agentshield_0.2.980_linux_amd64.tar.gz"
      sha256 "ebd5eef98e210e4dc90d48d07a383263829c1d85bced1683bd1cac723c4bcdfa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.980/agentshield_0.2.980_linux_arm64.tar.gz"
      sha256 "1d8d4620a774337bf55e78a9f62f94660dd5bef102a04ddcbcc8b64fb01e7203"
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
