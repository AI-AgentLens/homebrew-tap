cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.563"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.563/agentshield_0.2.563_darwin_amd64.tar.gz"
      sha256 "dabfa3db701672544109a2fdd3f8c1b408204e65860d4397d542b808be478aa6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.563/agentshield_0.2.563_darwin_arm64.tar.gz"
      sha256 "7724c08ddd11f53a6644859d0145d0859d3d1658c89fed10be784752d277d2c0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.563/agentshield_0.2.563_linux_amd64.tar.gz"
      sha256 "5708c538a2f9d53810f69e35235b74f1b67e62685a7e5dc6d85b33bfe6fd99d2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.563/agentshield_0.2.563_linux_arm64.tar.gz"
      sha256 "54fc0231505134b430a1da6c3ac976cf31715e7f1aabc041c505c72c38947e27"
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
