cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1343"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1343/agentshield_0.2.1343_darwin_amd64.tar.gz"
      sha256 "45ed2422ac759045d3797e1cb0c2292bd3271b8b7bcf269b50ec65498263481c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1343/agentshield_0.2.1343_darwin_arm64.tar.gz"
      sha256 "33f5f5429f486a41ce9af40b6187fe2f338f3799045180b8b798f4cf6fa5bbba"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1343/agentshield_0.2.1343_linux_amd64.tar.gz"
      sha256 "e263c5263d1b37af6eac9eaecadc7d9215bbf0076ad54eaf440706e6471b8969"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1343/agentshield_0.2.1343_linux_arm64.tar.gz"
      sha256 "3a96a27eb59587803f65544e68023bba13ec30075213533cc3c9fc6d2baaae3f"
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
