cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1612"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1612/agentshield_0.2.1612_darwin_amd64.tar.gz"
      sha256 "1a9438d6c4cbaaab8603b970974d50dca894297fc7a1b33bee628a8fe6cb7960"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1612/agentshield_0.2.1612_darwin_arm64.tar.gz"
      sha256 "6e30dd37d4a162a30e628605c7f5be04a0406e71555a08b8967987ca2d2273a3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1612/agentshield_0.2.1612_linux_amd64.tar.gz"
      sha256 "cfb4c21c98bc996f127c69150d18a5e67d628d2594a839f724d844548bc3392e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1612/agentshield_0.2.1612_linux_arm64.tar.gz"
      sha256 "9990df50a2dfcddf4ed7e1c22083057604df185be9677b5a60735c5d2dc994a4"
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
