cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2158"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2158/agentshield_0.2.2158_darwin_amd64.tar.gz"
      sha256 "2ed48ef9d1eb329e8958e73d43efdcbd22bea7c5d779ec04bf94c0e29603de06"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2158/agentshield_0.2.2158_darwin_arm64.tar.gz"
      sha256 "b4ff534ca64c0181312ac8c45767889ba13ad3f4f092098b67d5e13b59d376a0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2158/agentshield_0.2.2158_linux_amd64.tar.gz"
      sha256 "71ea65377a7c4bf5a8a9b3129049bc428d4bfde67b8c840947fb1a250c7e5b64"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2158/agentshield_0.2.2158_linux_arm64.tar.gz"
      sha256 "8ae51c2181724ebb1387b4ebbfb8c16f84709ae8e085141cb5b2b26d1006a6ee"
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
