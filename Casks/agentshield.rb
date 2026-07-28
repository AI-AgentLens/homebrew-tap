cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1741"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1741/agentshield_0.2.1741_darwin_amd64.tar.gz"
      sha256 "dfd089cff49b41fca00306996dd0479df7f6bca47a5875cddbc7500ba2168cff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1741/agentshield_0.2.1741_darwin_arm64.tar.gz"
      sha256 "0e6ad327e978c2ce8e4de6c514940482a2f00caf70091e108eb2328775ff39de"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1741/agentshield_0.2.1741_linux_amd64.tar.gz"
      sha256 "92551816b56ae31b8ce573fae380ce7476a327a311b129dceea33aec0c2bd232"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1741/agentshield_0.2.1741_linux_arm64.tar.gz"
      sha256 "4cd2f9b1251828d6cf85f6d68c71a88284eab47ce68249763f87fc57b844883f"
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
