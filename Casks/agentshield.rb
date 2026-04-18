cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.637"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.637/agentshield_0.2.637_darwin_amd64.tar.gz"
      sha256 "8c4cdff523a1380365382ae73a28ff03eadbd0fd6680df14aa44fa4a8aaf3986"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.637/agentshield_0.2.637_darwin_arm64.tar.gz"
      sha256 "39222b18ad65b9273298443c63fdccabeec284a3954796debbacd53687f3ebac"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.637/agentshield_0.2.637_linux_amd64.tar.gz"
      sha256 "4fdca6fc8ad5809f8ee34c8adcbfbf575eb68165c2b0b500af419f0d5748e2b0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.637/agentshield_0.2.637_linux_arm64.tar.gz"
      sha256 "02cdfcef0472de5e2b43c96f10edff33d6029f754f00afcb446cee89da546c2b"
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
