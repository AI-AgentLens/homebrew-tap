cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.817"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.817/agentshield_0.2.817_darwin_amd64.tar.gz"
      sha256 "c212f8f6c4f0e40218d72b2e35c6f25cd644562365b4ce5e86cc34009d42e78b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.817/agentshield_0.2.817_darwin_arm64.tar.gz"
      sha256 "bf170debb5765f67fb564a0a958b9bb5fa946950741b4f2dae10a893ff36eacd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.817/agentshield_0.2.817_linux_amd64.tar.gz"
      sha256 "0d78b8e260c516e015f11ef9dda6cf0aad98dd4e28575aaca8238aa7bea7dccc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.817/agentshield_0.2.817_linux_arm64.tar.gz"
      sha256 "8696bb273e4ec6cd1563bdd3ea2b193926052e769eeecdba827202dc328eda37"
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
