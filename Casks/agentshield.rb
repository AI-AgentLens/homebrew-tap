cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2417"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2417/agentshield_0.2.2417_darwin_amd64.tar.gz"
      sha256 "4e5f51722de9db608521501bbacf3a25434512495a4e72e26795e4c63903a1dd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2417/agentshield_0.2.2417_darwin_arm64.tar.gz"
      sha256 "be4fdcc7ecb1c2d0f97f36081924578fd298147aed74ef87f3c48e96cd1be6ce"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2417/agentshield_0.2.2417_linux_amd64.tar.gz"
      sha256 "1ba4d410936af5e586216500f9f331ac1e2b951f4b7eac9b258d7cb284160aa9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2417/agentshield_0.2.2417_linux_arm64.tar.gz"
      sha256 "789df9d1c5c821704aa600e0512e200f7b39298e5e54b458093c8941e5182e61"
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
