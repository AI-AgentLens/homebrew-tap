cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1655"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1655/agentshield_0.2.1655_darwin_amd64.tar.gz"
      sha256 "f2bedec0ab2ea296e8cb2aefefcf47bf5db4a7e4d3e55003f6f1bcdfe84a9728"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1655/agentshield_0.2.1655_darwin_arm64.tar.gz"
      sha256 "ee2e73bc6c1b6bd398ed551caa1f09e6573cccb8701f6d1c3b7086c3a80f8bb8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1655/agentshield_0.2.1655_linux_amd64.tar.gz"
      sha256 "1b59bd1b17c99498234beee90e22e89fbc4b6ec96a713c764ab9c6b0fe5080ef"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1655/agentshield_0.2.1655_linux_arm64.tar.gz"
      sha256 "a145dc16fcdaf574faf6dbe11adc4e0dfcc985bbe9457117357c2c4693a13299"
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
