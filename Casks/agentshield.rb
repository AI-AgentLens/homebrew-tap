cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1895"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1895/agentshield_0.2.1895_darwin_amd64.tar.gz"
      sha256 "d4c5f47489055ce53c29ae1f7ef43c635f6dfb5963d2256294991760e2930a2a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1895/agentshield_0.2.1895_darwin_arm64.tar.gz"
      sha256 "c2903eb80b2e66800bf5be70ce78aacfd34d5d7fc0ce4aeff65d6f8c88005c9e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1895/agentshield_0.2.1895_linux_amd64.tar.gz"
      sha256 "a0887691adca26152b533d99c58f52ab23286e110798cd3b937e4df0ef3a5c3c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1895/agentshield_0.2.1895_linux_arm64.tar.gz"
      sha256 "3e56223d2d30b1c445b16caeb807cf8b60332887a7543b2f9e6ec0381efd766b"
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
