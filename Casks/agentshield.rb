cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.560"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.560/agentshield_0.2.560_darwin_amd64.tar.gz"
      sha256 "f2508ff5bdeb946e819b0d66cd7ba546dba80b5217fcb77a3a7e44a8c7eadaf4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.560/agentshield_0.2.560_darwin_arm64.tar.gz"
      sha256 "27cb2e1e4afc68560479070f2f3246a156f69b379ad1328319ac89c2d4b1ce42"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.560/agentshield_0.2.560_linux_amd64.tar.gz"
      sha256 "d685ca227e5b904b4868a5d01a495eca92aba821d7ae70418bc89d0b500187b4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.560/agentshield_0.2.560_linux_arm64.tar.gz"
      sha256 "9a36020c23c547a2b0fdee973c9f38792e1059cd00a2aaad7dd801ba8b16ee65"
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
