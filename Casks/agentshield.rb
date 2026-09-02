cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2021"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2021/agentshield_0.2.2021_darwin_amd64.tar.gz"
      sha256 "82fcd968ae9eb30ea69c579667b864c2e1fa0ad5d083af7498b49ede2cfbc8ce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2021/agentshield_0.2.2021_darwin_arm64.tar.gz"
      sha256 "20e0deb7e18cfa7595eb6d5e7c5b66d3f5ff6b2486808d13d6fd58c0d01f3a81"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2021/agentshield_0.2.2021_linux_amd64.tar.gz"
      sha256 "03f3be380f07f1aa25ea621a2825bce8126657538182e072c214d2580af6dcda"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2021/agentshield_0.2.2021_linux_arm64.tar.gz"
      sha256 "796937123f589bf51d37adf026e0622b61394130a5a90c41476b06f73cffbfa6"
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
