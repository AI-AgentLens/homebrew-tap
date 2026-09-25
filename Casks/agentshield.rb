cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2256"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2256/agentshield_0.2.2256_darwin_amd64.tar.gz"
      sha256 "ae9d2010cbdf991c03c87773acc47907814b9b2342b382b2c1d0ad99d344f28d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2256/agentshield_0.2.2256_darwin_arm64.tar.gz"
      sha256 "290d17a9e19277e322384f9968e424179ccda80fdcdc85bf07b558e2da3bc92a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2256/agentshield_0.2.2256_linux_amd64.tar.gz"
      sha256 "5e07f940068e1fae096b1f76c95d0a39787deaafb92176e4e8ca34616a7bfdf4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2256/agentshield_0.2.2256_linux_arm64.tar.gz"
      sha256 "635a7383471816b780ff6eff3968ba9420bcdca088dfd7707a03a94162c093e3"
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
