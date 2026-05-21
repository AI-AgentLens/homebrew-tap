cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1059"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1059/agentshield_0.2.1059_darwin_amd64.tar.gz"
      sha256 "318e552736a98850bf744f5aa21b8b134aef3bb8c37fe0f90b0700dddf7790ee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1059/agentshield_0.2.1059_darwin_arm64.tar.gz"
      sha256 "7ff6e5aaa65b890ab453bb2b35a4fd5d7c344a3d2da0d22e04cf802a792aa482"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1059/agentshield_0.2.1059_linux_amd64.tar.gz"
      sha256 "4699eac648641013877b7bf7a151b11cacfa7a20953fee7f865c5613a3c81efe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1059/agentshield_0.2.1059_linux_arm64.tar.gz"
      sha256 "281eb66c119bd7a9f3fb6cad8d960911bf8857c2c974da1f17cfba8663e2d49e"
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
