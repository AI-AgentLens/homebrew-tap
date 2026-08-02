cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1777"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1777/agentshield_0.2.1777_darwin_amd64.tar.gz"
      sha256 "d3a0789ef748a64ed28db4f830c6656763ae56bf55c24c5cee2424174edd52ea"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1777/agentshield_0.2.1777_darwin_arm64.tar.gz"
      sha256 "bb2bb24c77a94091750dfe467d08f1a9ac7d7ed6e2d1afbe8d8672e224e02330"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1777/agentshield_0.2.1777_linux_amd64.tar.gz"
      sha256 "719244e847e92143c57a50de8c556d1a61b3d339fa455da2cd0d1e6445a28cd7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1777/agentshield_0.2.1777_linux_arm64.tar.gz"
      sha256 "96aab0341e062df8a73646665f6129512287179ee28ecc99bdf7774eeff34fe5"
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
