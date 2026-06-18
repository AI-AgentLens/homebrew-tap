cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1359"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1359/agentshield_0.2.1359_darwin_amd64.tar.gz"
      sha256 "4d2fb2e9b90e1b9b44da35550ea0eab67498aec35079ef5677dc92057769763d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1359/agentshield_0.2.1359_darwin_arm64.tar.gz"
      sha256 "a1ed4735d214532385881ff715603324e0bceb8fdebe5ad80e9e2f5f5c4855c6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1359/agentshield_0.2.1359_linux_amd64.tar.gz"
      sha256 "d13709776441d12a4740971cfdf9c2d34ea7cd2f0792c49248fd17366391709b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1359/agentshield_0.2.1359_linux_arm64.tar.gz"
      sha256 "bc80db32f0126435124816086e9822adcfbd3db560261e459bdd610099cb1f08"
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
