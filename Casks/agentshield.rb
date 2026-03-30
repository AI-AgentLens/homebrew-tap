cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.246"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.246/agentshield_0.2.246_darwin_amd64.tar.gz"
      sha256 "f367a49636ab93bec5401b786d5e25d6c553178e3fa387aee2a8871f52f9b444"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.246/agentshield_0.2.246_darwin_arm64.tar.gz"
      sha256 "3efa21deddba5db0c4ff664df3f81856eb4ed69798745e2c564f6b5eb4afeda0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.246/agentshield_0.2.246_linux_amd64.tar.gz"
      sha256 "f85cbab0644eaac755caaa7453401afc97a19793608b700df5e342f36ac6126a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.246/agentshield_0.2.246_linux_arm64.tar.gz"
      sha256 "8051057090d964a1bf55a1359a4590701a8e85f054586b4d7a156b8a80e680ff"
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
