cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2412"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2412/agentshield_0.2.2412_darwin_amd64.tar.gz"
      sha256 "34dd4cced6e9e93cea9f4034c2c88a3b0f0dde255d31728dc7790cd7b4b2f99e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2412/agentshield_0.2.2412_darwin_arm64.tar.gz"
      sha256 "069aabbdf024223ec60e80f9758b2f42627f65dcdd0cd64e546c49556f9e2c19"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2412/agentshield_0.2.2412_linux_amd64.tar.gz"
      sha256 "52b042e1e7bcd502eb04010354ecc122b5b395f39a29b5af6178a01f30a04d36"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2412/agentshield_0.2.2412_linux_arm64.tar.gz"
      sha256 "9d9e6c00f394fd5e44c5f28b4c4fb29f11a400cc248966021f3d0d6387b2d477"
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
