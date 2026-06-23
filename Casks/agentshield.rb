cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1423"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1423/agentshield_0.2.1423_darwin_amd64.tar.gz"
      sha256 "490cd75c7b1d93c00de4fa81e674a04039d9c631b9dc205e357aa410d641e508"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1423/agentshield_0.2.1423_darwin_arm64.tar.gz"
      sha256 "9bc887d26021b44a1c89afb743c780551b3b77b07de4a47ff5fe390e567c4321"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1423/agentshield_0.2.1423_linux_amd64.tar.gz"
      sha256 "52a660f8232f876bad86737647ff792f517b2f679f324999f55a0afa90eb4c95"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1423/agentshield_0.2.1423_linux_arm64.tar.gz"
      sha256 "d000785711c346a4c0f853100f11f7ea6ae96994553d41aa3688657106828fdf"
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
