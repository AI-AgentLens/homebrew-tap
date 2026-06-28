cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1479"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1479/agentshield_0.2.1479_darwin_amd64.tar.gz"
      sha256 "4aa84a73407da9c7e4a2b8374c45f39e97dade621a274fea9743aed2cfbb85d2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1479/agentshield_0.2.1479_darwin_arm64.tar.gz"
      sha256 "6c1349ade3d28f21db57bee50ec8d3e8ab520750555940bac7d7b675fa1c2027"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1479/agentshield_0.2.1479_linux_amd64.tar.gz"
      sha256 "5336a64dfda8219cf8b7536b5268d93b3690f05be8f7882812ce573f867b7222"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1479/agentshield_0.2.1479_linux_arm64.tar.gz"
      sha256 "65bbcd506738a43ad0d4928344603020c658fc2277be2498c6e0b0e100f864c1"
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
