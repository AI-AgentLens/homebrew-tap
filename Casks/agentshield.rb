cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1878"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1878/agentshield_0.2.1878_darwin_amd64.tar.gz"
      sha256 "684bc066c2a4593407cd108007f041aeaba73f9035de3db3d85bf4816aa4ddbb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1878/agentshield_0.2.1878_darwin_arm64.tar.gz"
      sha256 "387d10d286eeaa98d5182c7e2260d54364dd13eb164f9baf225933ffc5368b33"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1878/agentshield_0.2.1878_linux_amd64.tar.gz"
      sha256 "63bb380d8ab67271422e1d7bfda5b43ad2d90af5cd558aa4b35ad75021836a5e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1878/agentshield_0.2.1878_linux_arm64.tar.gz"
      sha256 "4d57713ea73935c0abfd87217180fe95b08fdcce2cf114b4e7594213147f8b3d"
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
