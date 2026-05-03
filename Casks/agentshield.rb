cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.870"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.870/agentshield_0.2.870_darwin_amd64.tar.gz"
      sha256 "eed4471d0ca152789bd371bd48249efc82a27cf3c00a501d59f218b1a11cd084"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.870/agentshield_0.2.870_darwin_arm64.tar.gz"
      sha256 "a146e22d10e0127457a53c8240fb028b7f8f123b6a36db78c5f1e44531f0e8f2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.870/agentshield_0.2.870_linux_amd64.tar.gz"
      sha256 "3d7c1e72ae889ecb69fa186197f91b7831f8ca0b4eb9177835e3369c46c7a606"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.870/agentshield_0.2.870_linux_arm64.tar.gz"
      sha256 "ee53d1e5a232250f6d8175c839553cddc3f99af0cfdcf225be4f0d4d1e00afbd"
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
