cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.99"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.99/agentshield_0.2.99_darwin_amd64.tar.gz"
      sha256 "8a0fece952bc706a5eccfbe45263d81bf65d77cb56f228ac3f6202268b78bc5f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.99/agentshield_0.2.99_darwin_arm64.tar.gz"
      sha256 "acffc0a028c915187018749d311800b1d032e4da4100a490b45a89e41a982819"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.99/agentshield_0.2.99_linux_amd64.tar.gz"
      sha256 "f172e14d2a69dbd9eb80070b1e25d2232f184b7c3c6e95fa8e19a25800d9d8f6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.99/agentshield_0.2.99_linux_arm64.tar.gz"
      sha256 "c321109c1e46b2de290a86d6831d3ec6ac4828b89e1722f40094217d2bb8cdc1"
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
