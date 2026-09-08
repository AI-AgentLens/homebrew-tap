cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2087"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2087/agentshield_0.2.2087_darwin_amd64.tar.gz"
      sha256 "1dc7c650bb7e2d97693b0198ebd19db1d24631fc9249fd795e4eb3a9cb38b414"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2087/agentshield_0.2.2087_darwin_arm64.tar.gz"
      sha256 "f9d80724a6848101dc6915c40723cfea584b34a340696d0cb255a635cfd30779"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2087/agentshield_0.2.2087_linux_amd64.tar.gz"
      sha256 "b834b652a0b667a299b2d43a8d875375fa3467a59cc00870220133944e9db064"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2087/agentshield_0.2.2087_linux_arm64.tar.gz"
      sha256 "66493e74747b515d89f8afba713fcd9677c055d81c67b623670154af9d499faf"
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
