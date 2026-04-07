cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.472"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.472/agentshield_0.2.472_darwin_amd64.tar.gz"
      sha256 "951e89e5aedeb62075b33a560eafddb07942a18dea9f1d7021ac7c6aa7eb8bfb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.472/agentshield_0.2.472_darwin_arm64.tar.gz"
      sha256 "482e5de9bb86ae7e4e1f04c43159eb6c53fd8307d437a2f384ccef804abe6eec"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.472/agentshield_0.2.472_linux_amd64.tar.gz"
      sha256 "41db9281a896247e663839e3925d3820333dfa01d41aa1690514e59bb5641021"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.472/agentshield_0.2.472_linux_arm64.tar.gz"
      sha256 "cb282e1cb928c8c94b2dfc0477a9a1d54c1c3c7fb43bcce01014c76f58d33d38"
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
