cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1584"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1584/agentshield_0.2.1584_darwin_amd64.tar.gz"
      sha256 "1b50b60d27c001bbd796ae9e4cbd47d0f587c32151c8893e62610d3a99f40398"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1584/agentshield_0.2.1584_darwin_arm64.tar.gz"
      sha256 "b3129737e0c374e058e55aa9cafc0a918c28fb9fa4c78943df464be24eadc92f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1584/agentshield_0.2.1584_linux_amd64.tar.gz"
      sha256 "8635eb1aea8f8d580b893be645c621708c20361687bc198b72b7d70b71f499b8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1584/agentshield_0.2.1584_linux_arm64.tar.gz"
      sha256 "70dc2e3ae5c2111c7592829fe5f5df62a0a1f06c0f9db4543c8b7b15fee32c13"
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
