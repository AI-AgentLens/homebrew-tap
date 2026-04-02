cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.341"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.341/agentshield_0.2.341_darwin_amd64.tar.gz"
      sha256 "986b40399e60f3bd8a25a53d4946de1c09770f81877ff5e95cd6bb4c7b017197"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.341/agentshield_0.2.341_darwin_arm64.tar.gz"
      sha256 "d23572fcb10827d35d15ba6d43c4799ad248f27c4ecec790153bd8b2bc162633"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.341/agentshield_0.2.341_linux_amd64.tar.gz"
      sha256 "f6386b6b334f97e46347b895333ee9c7cffe828f245ae4bc52343e9b9b077f97"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.341/agentshield_0.2.341_linux_arm64.tar.gz"
      sha256 "f6196c1468f1e1dd51e398baecc28d43ae7745364db2503cf78305e821e5538e"
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
