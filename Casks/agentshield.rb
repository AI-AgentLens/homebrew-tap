cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2461"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2461/agentshield_0.2.2461_darwin_amd64.tar.gz"
      sha256 "2d9386a870fe36178afd8e79834b4de84bb301543346017b7074deca4025ceeb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2461/agentshield_0.2.2461_darwin_arm64.tar.gz"
      sha256 "2c3aaa0f79bbef77c0615d8d952387f963a46e193815c9b288483f15da4336f1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2461/agentshield_0.2.2461_linux_amd64.tar.gz"
      sha256 "d0193a3845b3947316091b26d5cc3611152ea390f8cf5850487390ae9f38c0dd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2461/agentshield_0.2.2461_linux_arm64.tar.gz"
      sha256 "73e2f73b2a3e5b9b800bea78eff2ea9e6da239d1f0bc0a9bf61c0a0eb843324e"
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
