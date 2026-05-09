cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.923"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.923/agentshield_0.2.923_darwin_amd64.tar.gz"
      sha256 "f507ab446d49267dc09320fd5a98fca0b6c1c4fad89a72fdc799b7d40c96fdec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.923/agentshield_0.2.923_darwin_arm64.tar.gz"
      sha256 "3096c8f66b95fbdd9155dcc36a91a25dc9e8e12d063341ed873a48a62035bdf9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.923/agentshield_0.2.923_linux_amd64.tar.gz"
      sha256 "d92e57459334e770a2043e83e8ba6b03da989169c6c2abfb03478a1411b25b80"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.923/agentshield_0.2.923_linux_arm64.tar.gz"
      sha256 "161a446534a66093b786e716ac5bde5415d9e35e9ef8cf47c16eacd264775323"
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
