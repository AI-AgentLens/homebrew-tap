cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1974"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1974/agentshield_0.2.1974_darwin_amd64.tar.gz"
      sha256 "07c74682993c3fce0dc13c0c9992d884f79c84112f620ee60e8d64b51ad8aa6a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1974/agentshield_0.2.1974_darwin_arm64.tar.gz"
      sha256 "c44294331550dcd435fc5296490d249a9f291583bb04352e36838396d00a45c5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1974/agentshield_0.2.1974_linux_amd64.tar.gz"
      sha256 "a0291fb9910c880c014f6b1839a974f63b07acd3ae361dc7c8a301811666bef6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1974/agentshield_0.2.1974_linux_arm64.tar.gz"
      sha256 "12956889b95eaadac1d7a84836c5b2e991a3d94d66c727a4c84364f686c9e0ec"
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
