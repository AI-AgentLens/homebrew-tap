cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1915"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1915/agentshield_0.2.1915_darwin_amd64.tar.gz"
      sha256 "5b66fda635c2de443fc185082a0d2dfa731a2b5f075e9c7e4d51ed558ae2d331"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1915/agentshield_0.2.1915_darwin_arm64.tar.gz"
      sha256 "4a0e4201e21328af972c5038bf8cceec76f65d74de2f3d849421da12162f7925"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1915/agentshield_0.2.1915_linux_amd64.tar.gz"
      sha256 "a2e04836bc3d74a0021cbdb19788003c75bd8f645fd3356435ca94af3cec8466"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1915/agentshield_0.2.1915_linux_arm64.tar.gz"
      sha256 "d255957562064f09f344aa03b2cddb01848a5a6b43282d281a053cd6213b657d"
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
