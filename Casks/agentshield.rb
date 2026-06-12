cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1295"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1295/agentshield_0.2.1295_darwin_amd64.tar.gz"
      sha256 "1612e12bfe107932906f5cdf012c08d2a9eb2e1210ccec0ebaf55ce37f84d529"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1295/agentshield_0.2.1295_darwin_arm64.tar.gz"
      sha256 "4e89814b4af5638cbef8fb42f4dcc91379cee8545d9c52ddccdb8bcad963cc51"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1295/agentshield_0.2.1295_linux_amd64.tar.gz"
      sha256 "a70321b252361b320bc85bdafa73ea96f1aade9703b43814ddc4751315e82776"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1295/agentshield_0.2.1295_linux_arm64.tar.gz"
      sha256 "ec60467bb6c6b6c1a03bb62492df720b118fcbed004a68e75693ae0aa05df3e1"
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
