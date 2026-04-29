cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.812"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.812/agentshield_0.2.812_darwin_amd64.tar.gz"
      sha256 "b033474d8b2f880f9d7f011e13dc1643725587474eb8f16cd6026014890bb193"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.812/agentshield_0.2.812_darwin_arm64.tar.gz"
      sha256 "60ea6884c5c4dfba5dd10ea526b096997ae977c62d42682e004ffab4ba1b3730"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.812/agentshield_0.2.812_linux_amd64.tar.gz"
      sha256 "0797f8c83f42f9e56a36e9abc29c5c8f80b5c01e96f1d036a46519cc4b049577"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.812/agentshield_0.2.812_linux_arm64.tar.gz"
      sha256 "199ec179960c2ae4bff98fa06ca31f90d79ff8595ae038de88420d7e07b7e257"
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
