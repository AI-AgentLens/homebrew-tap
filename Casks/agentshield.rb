cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.672"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.672/agentshield_0.2.672_darwin_amd64.tar.gz"
      sha256 "04e259ad593dbcfd33d6ebf7ebc5ca4f565983c9bc43dabf03c00eca1073b85c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.672/agentshield_0.2.672_darwin_arm64.tar.gz"
      sha256 "428de44cbdf7e0bab8cf6768cdb0c194035e68a02906be957c1c1bc2053b160e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.672/agentshield_0.2.672_linux_amd64.tar.gz"
      sha256 "fbf7a27dff21adef4082f484c27f1d428188c101b5975125fa1b925136ab11dc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.672/agentshield_0.2.672_linux_arm64.tar.gz"
      sha256 "78d15c5ee5291f6d6817a7a324d1d7692058ed212d9257b7f825b2a3f3d18823"
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
