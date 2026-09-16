cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2161"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2161/agentshield_0.2.2161_darwin_amd64.tar.gz"
      sha256 "c86f16b40be15c68d33d2c97e70b455d898e1585302cdd054a390d99d39131a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2161/agentshield_0.2.2161_darwin_arm64.tar.gz"
      sha256 "7ce33f08ae6856683b41700494c26c00f6f063d88833a1dc0993cb9cc3e251d7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2161/agentshield_0.2.2161_linux_amd64.tar.gz"
      sha256 "a2ebeff2127b2b951e2f95273380ed1f739a478b4743e76d4749f6bb68c3a144"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2161/agentshield_0.2.2161_linux_arm64.tar.gz"
      sha256 "9b7f2e23b1ee6775c29629c873b6ab43cffba084e5ac6de4355a10769e121fc9"
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
