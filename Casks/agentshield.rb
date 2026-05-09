cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.925"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.925/agentshield_0.2.925_darwin_amd64.tar.gz"
      sha256 "1c0772d3422fde0c237f2b380a8c9980bc02b3a7f97d868d3ca5730119cdaedb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.925/agentshield_0.2.925_darwin_arm64.tar.gz"
      sha256 "3ab5eafa8cca468d90bef89c9419c9ef67ae74965722302f22e250c3eab46382"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.925/agentshield_0.2.925_linux_amd64.tar.gz"
      sha256 "1a2a030d664afd77064be3093fb16686c4a8b04d8da04917c3624db2b2ede125"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.925/agentshield_0.2.925_linux_arm64.tar.gz"
      sha256 "86f4d7a679dd0b940004c174b214826aa241c0444fb706370ae4f4f47516fc72"
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
