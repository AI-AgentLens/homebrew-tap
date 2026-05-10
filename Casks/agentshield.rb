cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.942"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.942/agentshield_0.2.942_darwin_amd64.tar.gz"
      sha256 "35cce887495e4917adc95a3512495eeae69876222da32bc5ee4bd9ac64cc8f9c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.942/agentshield_0.2.942_darwin_arm64.tar.gz"
      sha256 "05e88b1f341177d46a0dd941f5ade8c03ad02548136ab3dc48eb262197587058"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.942/agentshield_0.2.942_linux_amd64.tar.gz"
      sha256 "671f9c7f46807b48b1dfb94d0b3ce0f7216b460fe2d7a7253843c347f11e501d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.942/agentshield_0.2.942_linux_arm64.tar.gz"
      sha256 "b85ff7ed1147140328f3057fe8ad1bd44b6fe145acb47e64a71daba07ec0c007"
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
