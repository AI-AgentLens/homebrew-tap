cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.192"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.192/agentshield_0.2.192_darwin_amd64.tar.gz"
      sha256 "a84cc5ee160bb84a6df6dfc046ee0a23cbf5f12afaf7aba01dde8be7656d72eb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.192/agentshield_0.2.192_darwin_arm64.tar.gz"
      sha256 "163b975eba1b621f238a037272f9bb27da3a036f2626fdcee487a2c27b30083b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.192/agentshield_0.2.192_linux_amd64.tar.gz"
      sha256 "65b080f3b3a9bdf2aea167731c8cdf86520b05b22b4630204646ec09d00fbe8c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.192/agentshield_0.2.192_linux_arm64.tar.gz"
      sha256 "f7df49db8cf0e888449a576e6315fdd7be1c701f8239906f809c6764dcbc2cee"
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
