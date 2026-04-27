cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.765"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.765/agentshield_0.2.765_darwin_amd64.tar.gz"
      sha256 "3f476335a7ed1fb013f65a1ed566cfdf00ccd566d5a1731af725ee2701e55c29"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.765/agentshield_0.2.765_darwin_arm64.tar.gz"
      sha256 "103baeb0f5c4425c46a0c59ad50ae91a106753820e2deaadf18b55e6636574f1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.765/agentshield_0.2.765_linux_amd64.tar.gz"
      sha256 "ba3a6a5e398dee8a7bd2bf85dfc65833116c40a1827b1f84d3923f0af122cd44"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.765/agentshield_0.2.765_linux_arm64.tar.gz"
      sha256 "e36bcd0a2ded2a4bc358e8da753dccbb177f2d2a52a5db0b7889d5e0ce9224e4"
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
