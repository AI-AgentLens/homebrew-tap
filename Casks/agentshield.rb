cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1421"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1421/agentshield_0.2.1421_darwin_amd64.tar.gz"
      sha256 "97df0113daf31dbe4e7794c9b5d15db5f6fb568962eb9dd186586be482097bbb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1421/agentshield_0.2.1421_darwin_arm64.tar.gz"
      sha256 "a9906549a8e14de7e443133b7c79e9a650319d3df44fd63e517bb58f70313f43"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1421/agentshield_0.2.1421_linux_amd64.tar.gz"
      sha256 "9e2a0878dd9ded132737cfe3e82e5dcacad0cd98c948889f01fd1ec65c8b100f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1421/agentshield_0.2.1421_linux_arm64.tar.gz"
      sha256 "b3a0957c73db206a33a8405536a9d3b003bf4786806e220a514b41a48bf1ef9b"
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
