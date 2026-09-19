cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2180"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2180/agentshield_0.2.2180_darwin_amd64.tar.gz"
      sha256 "dc88d4b4adf6c0ca36afe24f869ce7cae56f47d59e20610dd242a6cf9ffbe1e6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2180/agentshield_0.2.2180_darwin_arm64.tar.gz"
      sha256 "5c176ba073497fd7b9871294195b11d19903f89a54bf6e50c76bdbcd57ae4a9e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2180/agentshield_0.2.2180_linux_amd64.tar.gz"
      sha256 "a25b0b29975c4fcff03be924caed96e6b43bc6c1a5f1b5fc587a803f161f2eb5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2180/agentshield_0.2.2180_linux_arm64.tar.gz"
      sha256 "0f1462532afcb0448d29fc93ee267133843da1d257f20d2f3c8b77d940ff1b1f"
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
