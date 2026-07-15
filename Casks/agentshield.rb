cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1652"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1652/agentshield_0.2.1652_darwin_amd64.tar.gz"
      sha256 "14f254eadc6f98e312da0549ac7b3bcd55a1bda521610de999cae24d496a4f5f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1652/agentshield_0.2.1652_darwin_arm64.tar.gz"
      sha256 "ef2213d942ac0460a2a2eff1ebac3d9972e1be251fd1733d73b2b244bdc4704e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1652/agentshield_0.2.1652_linux_amd64.tar.gz"
      sha256 "5177d4147089ac5059568991a4e07cdb6f658f5dcb5762a125e89d2ec1c004ce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1652/agentshield_0.2.1652_linux_arm64.tar.gz"
      sha256 "9af9181873bc4d2dc990da896d699ac5a4fdf08a678709414c6c46b57627fbfe"
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
