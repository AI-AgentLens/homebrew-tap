cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1384"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1384/agentshield_0.2.1384_darwin_amd64.tar.gz"
      sha256 "5d1e91cac89de8ffcf41a8bf9c7aa5d0e517d8939465bfbe8a773abb70d3d50c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1384/agentshield_0.2.1384_darwin_arm64.tar.gz"
      sha256 "40950043fa0ea4d11e241da968b3605deac954e8a9422eae115f04d15cf21714"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1384/agentshield_0.2.1384_linux_amd64.tar.gz"
      sha256 "4e0c25a3354f4737a070d0a323ad230646dee335dbd1185693d02afb3d121ca3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1384/agentshield_0.2.1384_linux_arm64.tar.gz"
      sha256 "81b916a5be028ed3d5fd527e405334008514f6da8e429e3b58e2c2151be3305f"
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
