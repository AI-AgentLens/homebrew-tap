cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.818"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.818/agentshield_0.2.818_darwin_amd64.tar.gz"
      sha256 "2f29ed9541f2f648d90a33a5ec5e0125f90f16774e1df83a9e2ecfcaabfc331f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.818/agentshield_0.2.818_darwin_arm64.tar.gz"
      sha256 "9b0174e44011a46fdc7460647708c3a424ab36f2ee65b7d7f2e2f33d629ff893"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.818/agentshield_0.2.818_linux_amd64.tar.gz"
      sha256 "da0364a672785ad57e1a6ab96646e13d7b1dd271e78a3e7b97cedbf7414f5b32"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.818/agentshield_0.2.818_linux_arm64.tar.gz"
      sha256 "673f2b6fb624a149a85541d0b1531334c70546eb27a0551af70890b0c5dc8770"
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
