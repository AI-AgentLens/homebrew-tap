cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1506"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1506/agentshield_0.2.1506_darwin_amd64.tar.gz"
      sha256 "b88b8a3675a5ef565ba0d5369400aa55df9c400aa3e81cff9c70a9eb1e0b7f13"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1506/agentshield_0.2.1506_darwin_arm64.tar.gz"
      sha256 "59c09fb90007353c9c10543f3614f7bc97bdfede1effb209972b3de87241f8de"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1506/agentshield_0.2.1506_linux_amd64.tar.gz"
      sha256 "0445eb86d618f98816b02b69244197f51bfc51b1d18d7098d8edbd0edb3302ee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1506/agentshield_0.2.1506_linux_arm64.tar.gz"
      sha256 "cad9fd42759e15fdd9f1003ffc676793662640735a6a37b200c6e6280fe64bd6"
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
