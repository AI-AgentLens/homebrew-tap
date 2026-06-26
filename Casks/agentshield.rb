cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1451"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1451/agentshield_0.2.1451_darwin_amd64.tar.gz"
      sha256 "b82eac4853910686df7b9ecf66fd5b188eb9ee2621de243822fdc098d7ced683"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1451/agentshield_0.2.1451_darwin_arm64.tar.gz"
      sha256 "f3a73b85bc0762f9eb78253b48c548b013cec42f07579ee986cc09b8aa224eca"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1451/agentshield_0.2.1451_linux_amd64.tar.gz"
      sha256 "61ceb628c6bb4040f90ce6581e784b6ee9d64cc2a82d68ad1a3a681ab4392aa5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1451/agentshield_0.2.1451_linux_arm64.tar.gz"
      sha256 "5737f70900e31174b01dc452cab8faee13e03db1b0ad9ff943ee5fa5f310456c"
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
