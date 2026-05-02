cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.854"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.854/agentshield_0.2.854_darwin_amd64.tar.gz"
      sha256 "07e62ab7b9418ce6d7d9bb150f6c3af996774d75698f002bdb96e80bb7b2df4b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.854/agentshield_0.2.854_darwin_arm64.tar.gz"
      sha256 "07e74e3e80c2179445121e73c6c131ac29c1a9e665d2537dc107c2c2812b8f85"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.854/agentshield_0.2.854_linux_amd64.tar.gz"
      sha256 "f2214598dcc5390b1bb4e58ae729406227799893c36f68b6091903a32d337c80"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.854/agentshield_0.2.854_linux_arm64.tar.gz"
      sha256 "715bd97be841504786c33dc90140e1bd6046a7ff8c2281a16c64ee48621afc9a"
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
