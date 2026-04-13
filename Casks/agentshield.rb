cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.571"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.571/agentshield_0.2.571_darwin_amd64.tar.gz"
      sha256 "cf1f2a9d5662d8bad9c9554552a7c9829d15b3dc7c68ac54504ceaaf2a36e084"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.571/agentshield_0.2.571_darwin_arm64.tar.gz"
      sha256 "a2c77bc3b1fa1011764702547aa0a21f72b72cd699d6fe53a7d168593c080578"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.571/agentshield_0.2.571_linux_amd64.tar.gz"
      sha256 "877b9db5fe55f36147fdc7a6ab381367176291f6fa2498a3363ffe93ad38b049"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.571/agentshield_0.2.571_linux_arm64.tar.gz"
      sha256 "fe8dde6bfa7292d6fa5a431c0b414fb9dd8470b1cebc0512565b50d93a1bec22"
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
