cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2482"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2482/agentshield_0.2.2482_darwin_amd64.tar.gz"
      sha256 "7998d2fc15ab73a06f2cbec666e4ff2d3c2b7280f582f15d1ec753b7e0040123"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2482/agentshield_0.2.2482_darwin_arm64.tar.gz"
      sha256 "456ebcb058511bf508e8eebea1243c274c41ba07d7263071d227a022c770d1c8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2482/agentshield_0.2.2482_linux_amd64.tar.gz"
      sha256 "97b97cd1918811e7220c4de94ec2aa25f4ce538d1961fc83eebba4fdfb77eeed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2482/agentshield_0.2.2482_linux_arm64.tar.gz"
      sha256 "9d9e2b96d741b0d20f21108d3cbdcac48f20657ba4da24379de6e6c00dc5cb8b"
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
