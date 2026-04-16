cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.605"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.605/agentshield_0.2.605_darwin_amd64.tar.gz"
      sha256 "9b7553bd9992fc0616a2ef13c2010d4bf0091be0ddc6459b134c278b44bb6504"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.605/agentshield_0.2.605_darwin_arm64.tar.gz"
      sha256 "24ab55611bc7fccb5368d3c48674726ff6f8ea4349540b76556db7433f9bed3d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.605/agentshield_0.2.605_linux_amd64.tar.gz"
      sha256 "11b642f92b1645795869e8ffd3682d09126f7bc8547dd2d2dd0191556a1c8310"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.605/agentshield_0.2.605_linux_arm64.tar.gz"
      sha256 "3270ec08ac8e3d9d0b238627310d3fbe89ab2d1a170f2c66b41ee500198b1612"
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
