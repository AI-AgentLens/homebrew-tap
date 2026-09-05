cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2050"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2050/agentshield_0.2.2050_darwin_amd64.tar.gz"
      sha256 "874794d5b0b66173a50bb3cceb6cbaaa2822b90f4f914abad47c67573426ee8c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2050/agentshield_0.2.2050_darwin_arm64.tar.gz"
      sha256 "1e9cf6fb678779d9bf2ef297d7cd6d859636f3692a2cbb862f8eaad5383142ee"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2050/agentshield_0.2.2050_linux_amd64.tar.gz"
      sha256 "744ce53d310954fd6e67e7655fc1a80d73bbcb5983c16bc5b105f459a27c94c0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2050/agentshield_0.2.2050_linux_arm64.tar.gz"
      sha256 "134519cb4d59ce22378a135d6a3045bc39b11f6842eee09e440b609d2be57ff4"
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
