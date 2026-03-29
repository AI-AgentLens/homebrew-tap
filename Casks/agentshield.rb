cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.180"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.180/agentshield_0.2.180_darwin_amd64.tar.gz"
      sha256 "d241bd38abd46ad3207096c27fce89cbf9385dbbececcf6ab03452079cde5a1e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.180/agentshield_0.2.180_darwin_arm64.tar.gz"
      sha256 "cfa51205add41ec3bf191399b7b55b68c2fb2d4e20b76a64916999ff2c8c4a3b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.180/agentshield_0.2.180_linux_amd64.tar.gz"
      sha256 "4f92ceb2df0e42a2cbcb0b0b96310ad2979656a25a461ff1ae34f7f619fe6547"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.180/agentshield_0.2.180_linux_arm64.tar.gz"
      sha256 "2c533a2721d204b3b7eb1aa6ba3504c86e03b6d419c009adca67c20493a423ac"
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
