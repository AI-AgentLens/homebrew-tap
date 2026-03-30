cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.223"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.223/agentshield_0.2.223_darwin_amd64.tar.gz"
      sha256 "273f1c8e4f767689287ac2c866444dd1a8caf756460ecc1a8b81feaebfcaad81"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.223/agentshield_0.2.223_darwin_arm64.tar.gz"
      sha256 "ca4f2b62a4976abbed6ecbc847fabe113c5a208131f40a80de99fd25ecfc4577"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.223/agentshield_0.2.223_linux_amd64.tar.gz"
      sha256 "cf737565b2f611523f9b1ddea2e066d1dc7e2865bc573bcb341e27efaed57ec3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.223/agentshield_0.2.223_linux_arm64.tar.gz"
      sha256 "97696f21e103fe9f2d7ed705854aa3b7782f03b142956e4a8c156a916f079ca2"
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
