cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1599"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1599/agentshield_0.2.1599_darwin_amd64.tar.gz"
      sha256 "447a6413cfd87ae3c6e72a55c511cbbb1c05e5e3e68be0d47a76c09c52e64227"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1599/agentshield_0.2.1599_darwin_arm64.tar.gz"
      sha256 "abf3292bcf5f79263b74a4dfc6c2e0f5c6b3f05a4e7fc7fa3322057c270e81cf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1599/agentshield_0.2.1599_linux_amd64.tar.gz"
      sha256 "5746ba315e030d364f6e780af964d1f5bd486fa703be68e86850da075180fa56"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1599/agentshield_0.2.1599_linux_arm64.tar.gz"
      sha256 "2238dbf185c898b671f52457b1b799bd0b382206230f6b2061f27a9956a19d6c"
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
