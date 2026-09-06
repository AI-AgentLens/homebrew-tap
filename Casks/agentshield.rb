cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2057"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2057/agentshield_0.2.2057_darwin_amd64.tar.gz"
      sha256 "7e21f5c86f62d812840d0dfb641407c54166b9b359866ea18111fc9fc3cdce03"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2057/agentshield_0.2.2057_darwin_arm64.tar.gz"
      sha256 "1a7ab3e2bf5b7237de0964ffc88abbe617bf2e0328adcfca04381f9e7dadd059"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2057/agentshield_0.2.2057_linux_amd64.tar.gz"
      sha256 "fd7195e67c90ba98a4c8bd0c0e6f22e572e92351797ea3e3678b0e0aa576d2b9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2057/agentshield_0.2.2057_linux_arm64.tar.gz"
      sha256 "33682339970166dc5ab4180e9a94838bfb5c8ea35896c32ec91c790623d421f1"
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
