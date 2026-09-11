cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2112"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2112/agentshield_0.2.2112_darwin_amd64.tar.gz"
      sha256 "2193bc4d515f93567de7430f7e5efa10409cc1ebeedfbd3e383232b840666cb9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2112/agentshield_0.2.2112_darwin_arm64.tar.gz"
      sha256 "780d1bfb7ae3b2825bafa8ecb0748645699fde22d9086063e87226826a1ccdb8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2112/agentshield_0.2.2112_linux_amd64.tar.gz"
      sha256 "507b6b854ebf1262b2e60c0414c56bb65913aa597556823af23dac03da48c350"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2112/agentshield_0.2.2112_linux_arm64.tar.gz"
      sha256 "1a673146e07d0c82f137431c22fb0891e247766ab13d458e646cde609fb36d92"
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
