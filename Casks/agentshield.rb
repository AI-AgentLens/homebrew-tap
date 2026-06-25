cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1446"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1446/agentshield_0.2.1446_darwin_amd64.tar.gz"
      sha256 "ab9eb435ffa3bb58e61312bd24031a00896063924693d742dc3354bfc60544dc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1446/agentshield_0.2.1446_darwin_arm64.tar.gz"
      sha256 "dcb5483ec99c6a403650af5352b89281060606693128c7d96ca312c901267fb8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1446/agentshield_0.2.1446_linux_amd64.tar.gz"
      sha256 "a7054e6f72c697a1c4624c8ce108f59545a049727e39efc7fc77dc6419813e12"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1446/agentshield_0.2.1446_linux_arm64.tar.gz"
      sha256 "91b2cac3bd19a1d89630159ed97d7a5420b1b7962d32784e0481e56b443286ac"
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
