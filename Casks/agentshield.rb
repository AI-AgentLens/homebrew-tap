cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1630"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1630/agentshield_0.2.1630_darwin_amd64.tar.gz"
      sha256 "713ccc692e8f956e8a457e63af26a645a03849f63784db6970a9cc4b1e3a107b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1630/agentshield_0.2.1630_darwin_arm64.tar.gz"
      sha256 "7ce574773b9ed90c516842d3725e5f396a0797c504fc455d1cbb553935d0b08d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1630/agentshield_0.2.1630_linux_amd64.tar.gz"
      sha256 "85c9905d5f025e767a6ea72896cec6522d5988e2175b056330745d263295d1e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1630/agentshield_0.2.1630_linux_arm64.tar.gz"
      sha256 "f70e5343d70fdbc58768a73e424119f2bcf79c0ac488611c4efbc65b9bf37c27"
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
