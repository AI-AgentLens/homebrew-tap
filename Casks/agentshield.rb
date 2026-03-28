cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.155"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.155/agentshield_0.2.155_darwin_amd64.tar.gz"
      sha256 "f85f547d0bb0d1b93f9ca260c6571160568d0e178cae999b5a15eba46addabc8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.155/agentshield_0.2.155_darwin_arm64.tar.gz"
      sha256 "6133f5908ed9b143fd1112a60429a718a61a09ae0b4da61566a656f0e7998953"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.155/agentshield_0.2.155_linux_amd64.tar.gz"
      sha256 "934457cad7b7f30b6136b43d8cd41228051586bc253f6417e2a8ed4640adc4ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.155/agentshield_0.2.155_linux_arm64.tar.gz"
      sha256 "8fbfd5caf4fc6112292e4cad76d68a01c09253950c0e4d82161d2f11269e7f3a"
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
