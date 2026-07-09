cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1595"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1595/agentshield_0.2.1595_darwin_amd64.tar.gz"
      sha256 "27b3de6c4797b5e67a5064bbc1145fa1e3136146f82d86f26bb544b03700b733"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1595/agentshield_0.2.1595_darwin_arm64.tar.gz"
      sha256 "6037a361b2760156d1d5eb30450968a9ff25edb09c6a06ba595dca1b8199cc7c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1595/agentshield_0.2.1595_linux_amd64.tar.gz"
      sha256 "c3c86606ace78d470d9abfb348978e7b2915b1d96afd5ccfadfe1c16315561dc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1595/agentshield_0.2.1595_linux_arm64.tar.gz"
      sha256 "6be1e87e77ee50488c570898f4c1d335e7d4caf90780d13832cb8db111ee3f83"
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
