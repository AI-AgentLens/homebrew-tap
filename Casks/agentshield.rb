cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1124"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1124/agentshield_0.2.1124_darwin_amd64.tar.gz"
      sha256 "2d16413c8306d7431a6cdb762a07c648ea5b57b895201464aba9b5f3c7eb6f79"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1124/agentshield_0.2.1124_darwin_arm64.tar.gz"
      sha256 "bbfcfdffe0c18708a2a7be294ab93f2e9f5511c4b343b0762e2c5d32ba9fb06c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1124/agentshield_0.2.1124_linux_amd64.tar.gz"
      sha256 "be61dd3f63b123c0e997d3041392980d10bad9f666ed74afaa37015060bdc27a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1124/agentshield_0.2.1124_linux_arm64.tar.gz"
      sha256 "c7635eb5f9595eaad75add6b1f13b1ff3458effd05f28dd82001e98e3d1ffb91"
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
