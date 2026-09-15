cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2152"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2152/agentshield_0.2.2152_darwin_amd64.tar.gz"
      sha256 "7df06aa8652a5d5f220b53cb71ec2c1ef810a7a110ca404b963e28283c8ddc5a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2152/agentshield_0.2.2152_darwin_arm64.tar.gz"
      sha256 "12fcd7b834e8d263e04f223b8ec284b70920dae7c37011dd7d6e66453532ef7f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2152/agentshield_0.2.2152_linux_amd64.tar.gz"
      sha256 "6798e125e96cb8e786a357cbc78430464a5f60653a62a5d269d4324095c85663"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2152/agentshield_0.2.2152_linux_arm64.tar.gz"
      sha256 "b0d83c326f5574c3883cae9d1d3018da37343bca4dbf7b05b0dea412264d8bce"
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
