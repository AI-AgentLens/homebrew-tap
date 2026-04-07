cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.452"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.452/agentshield_0.2.452_darwin_amd64.tar.gz"
      sha256 "375e5935cf3c80990bddc4e462e6bc02c175a071401b883d20737476cf281a4a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.452/agentshield_0.2.452_darwin_arm64.tar.gz"
      sha256 "38ff08374d936b259bf88b26658e0c660b43fe325868d2c8004cd1db5047bb14"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.452/agentshield_0.2.452_linux_amd64.tar.gz"
      sha256 "057b65525148ecba142526286b948d4debf9c009517d079d24ca787a125cb058"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.452/agentshield_0.2.452_linux_arm64.tar.gz"
      sha256 "503a1529b4217a06afb1637c1e72d726c2760111adcec958b3280242a013de49"
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
