cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1247"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1247/agentshield_0.2.1247_darwin_amd64.tar.gz"
      sha256 "472be4ccaf7cdd09ffff1f65be44705abe03cd19c08aadbc47b6abebc0d8fb64"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1247/agentshield_0.2.1247_darwin_arm64.tar.gz"
      sha256 "e48d391329ce86217503676f5330cbe5c44c7b56a866ac22f2a2c8ba9126afdf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1247/agentshield_0.2.1247_linux_amd64.tar.gz"
      sha256 "5cac6a701b7453327bf6e218ca13b3a773ee286e3b3e089832a5f7ce9b08385f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1247/agentshield_0.2.1247_linux_arm64.tar.gz"
      sha256 "3a267248eade750bc335692fe89c522c3e9095786a7eaee05dde92497bca45d4"
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
