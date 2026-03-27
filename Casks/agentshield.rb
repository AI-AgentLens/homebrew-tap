cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.95"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.95/agentshield_0.2.95_darwin_amd64.tar.gz"
      sha256 "55cc3dd5d2d4fff7728e576111c5b329d1f622a1a811d721ffe42000e4529995"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.95/agentshield_0.2.95_darwin_arm64.tar.gz"
      sha256 "566506348696e4d1796ca27c7147517899b87a8ec5d80abdda853ed8ca4bd381"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.95/agentshield_0.2.95_linux_amd64.tar.gz"
      sha256 "3e4d2c1adfc488d8aab9472d8cead84e8b5a2372f9e65ed71d3a6db4bc110eec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.95/agentshield_0.2.95_linux_arm64.tar.gz"
      sha256 "350530976dd2ba379fd218b1f9b70366f6b0b0c2121cc1fa0914e126653f7e26"
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
