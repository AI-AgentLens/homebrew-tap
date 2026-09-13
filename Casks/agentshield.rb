cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2134"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2134/agentshield_0.2.2134_darwin_amd64.tar.gz"
      sha256 "762337cf06493e7b53d33823dcdaadb50ba38138c51b2d9fa6615895956bafdd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2134/agentshield_0.2.2134_darwin_arm64.tar.gz"
      sha256 "9fc61a6d1b48ab801626df6ef760d4821990abccfcbc9815bc7cc0e1ec076e8a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2134/agentshield_0.2.2134_linux_amd64.tar.gz"
      sha256 "0e7ad4faaf48addf6cf87cb8b1bbb67addf705df996ad08109db53c6037ba5dd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2134/agentshield_0.2.2134_linux_arm64.tar.gz"
      sha256 "8c4cfcd8630f9911f2b9f9128ca2a0860ffb73e38a5a6da87c0e69bdf0b66498"
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
