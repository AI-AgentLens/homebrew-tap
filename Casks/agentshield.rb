cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.214"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.214/agentshield_0.2.214_darwin_amd64.tar.gz"
      sha256 "648acf9f3b8b1a8d4f7baf9b7e38ec626983ac78e99f8b1d78144a13d3626bf7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.214/agentshield_0.2.214_darwin_arm64.tar.gz"
      sha256 "46c1a450b3d1fe7b712a95d2e47b0b25c4018f59f4de9d876333ecfcac38e6e4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.214/agentshield_0.2.214_linux_amd64.tar.gz"
      sha256 "90c6fc15a9333a69d37b1c8a74b22e9ff1a5b2aa02dac8320ae5e89a10e61b72"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.214/agentshield_0.2.214_linux_arm64.tar.gz"
      sha256 "e61e34b68a67b610b98424964ec7759a31bb9cb4977134d638e7e7275378c912"
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
