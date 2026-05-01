cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.846"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.846/agentshield_0.2.846_darwin_amd64.tar.gz"
      sha256 "e9a376a5be9a4a5b21ee0fb188850e783d4f00ce5ec8180e5760a3d3434a2204"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.846/agentshield_0.2.846_darwin_arm64.tar.gz"
      sha256 "879d3653e2ad56092e9a2b499433aedc7624e75a099b06ed3bbd7bdd19732ac7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.846/agentshield_0.2.846_linux_amd64.tar.gz"
      sha256 "653da60e0d11018c1bcfb41bf72e0c58b3ba7d28b8e2ef80c0f6edeacf95e8c5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.846/agentshield_0.2.846_linux_arm64.tar.gz"
      sha256 "e26ac15fd627afdcad9cd8cb258b496333e0630870cb6657613331cf8f03864e"
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
