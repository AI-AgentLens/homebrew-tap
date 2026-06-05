cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1211"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1211/agentshield_0.2.1211_darwin_amd64.tar.gz"
      sha256 "598352e4fe10ee19084d853860beac04e0182a93f3ac1139198f07ed7acdc7b0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1211/agentshield_0.2.1211_darwin_arm64.tar.gz"
      sha256 "60aa43382b6c748cdfae16b68ede1781512541cbd2a6a28692faebf58adfefde"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1211/agentshield_0.2.1211_linux_amd64.tar.gz"
      sha256 "4450f7b7aa0b5fb19981ca3f9fc5371f3bf1cfd5708239696cd2e99f50c01004"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1211/agentshield_0.2.1211_linux_arm64.tar.gz"
      sha256 "c8cc1072e9ab61a2d3a4bbb8fb6022f74f08e5e8d590cf4c15597bf0df0b4eba"
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
