cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1480"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1480/agentshield_0.2.1480_darwin_amd64.tar.gz"
      sha256 "a828798d1944019be509b07397415d3d513ea78fa40383f34b8b72ded5b09874"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1480/agentshield_0.2.1480_darwin_arm64.tar.gz"
      sha256 "cbdd89e2101992222fc241fed8bd9ff2b90f14c41019ba4a292a998edd107b36"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1480/agentshield_0.2.1480_linux_amd64.tar.gz"
      sha256 "379bf38a114a7cb14ce46fdbb314952764eb136333b314f5d4dedb82f7d241d8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1480/agentshield_0.2.1480_linux_arm64.tar.gz"
      sha256 "841673dc2be166cd7d0fb6cd8a63ba21c8ea1fa7b5d13fa50438164c6984ec6a"
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
