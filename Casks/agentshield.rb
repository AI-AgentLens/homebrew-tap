cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.125"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.125/agentshield_0.2.125_darwin_amd64.tar.gz"
      sha256 "01daf23db7196e175a99a6d920f8ff0d9e1df1f45ff87680b9bec17492712dcb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.125/agentshield_0.2.125_darwin_arm64.tar.gz"
      sha256 "331bea2fdfb2727fbc4fdf91130626f02e4d6b6201ae22db45c81facef98c8df"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.125/agentshield_0.2.125_linux_amd64.tar.gz"
      sha256 "5f726843d2f0e1fa09e5fd49a168c3aa3269912d7ed79d0f7d7f795aebb53921"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.125/agentshield_0.2.125_linux_arm64.tar.gz"
      sha256 "b5def13ae031681e3d61093f5f9cd0e6456cb1164b729ae594746ab585ceafdb"
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
