cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2018"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2018/agentshield_0.2.2018_darwin_amd64.tar.gz"
      sha256 "2cb8912c8fbe91ecda66a4ae331ec036d67b1628f2ba6c9d77e07a89aa2aed92"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2018/agentshield_0.2.2018_darwin_arm64.tar.gz"
      sha256 "3547f0f811f26d71f24455139b5e28e9ecbd0bd75ad988ad1247b53fc1bc27dc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2018/agentshield_0.2.2018_linux_amd64.tar.gz"
      sha256 "aa1eecb6f66b35ea75186b765f4878f15ae2232510505cc1f0cdc25238312cfd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2018/agentshield_0.2.2018_linux_arm64.tar.gz"
      sha256 "d29d9236e5336022a10fa3a0c39ed420039cb6669948dfc27d854d7a2e101edb"
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
