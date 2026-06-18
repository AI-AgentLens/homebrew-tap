cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1365"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1365/agentshield_0.2.1365_darwin_amd64.tar.gz"
      sha256 "fcbbae402255292e6be1c665cb8a8032780045c1927a2da82c2b12dc406f4a71"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1365/agentshield_0.2.1365_darwin_arm64.tar.gz"
      sha256 "0306182544969a49051fb1b919d192d9ff3a093bf5d8c6579f978735e970a500"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1365/agentshield_0.2.1365_linux_amd64.tar.gz"
      sha256 "6f19d29767dfc75b72f50867cd900edd99a9929c147ca294fac24c51a2e51977"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1365/agentshield_0.2.1365_linux_arm64.tar.gz"
      sha256 "2dd82f48723d12324d4e78641899ea05ce878ebbfa15eb3e3dd6191e778eaade"
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
