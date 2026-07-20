cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1693"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1693/agentshield_0.2.1693_darwin_amd64.tar.gz"
      sha256 "fa29b96f58624a902a89c9d03cd0d8f7891e501282deba0904b2c06e701c495b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1693/agentshield_0.2.1693_darwin_arm64.tar.gz"
      sha256 "10acd9d968fc6a2bf8ca1207f739ee0e42cad9db9c19d0b0f6116169171e8497"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1693/agentshield_0.2.1693_linux_amd64.tar.gz"
      sha256 "8b1fa270e2c14aa41811763f95a929996d646d538ae53ebc230f0751b7068647"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1693/agentshield_0.2.1693_linux_arm64.tar.gz"
      sha256 "36a0ace73dda22609335ad7f3a127781132a3643017c16673bda935c954f38fb"
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
