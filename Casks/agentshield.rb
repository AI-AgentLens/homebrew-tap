cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1352"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1352/agentshield_0.2.1352_darwin_amd64.tar.gz"
      sha256 "c37240c146aba25d523b49c41905a9b28f90d4f814e47c26484cca555dff452e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1352/agentshield_0.2.1352_darwin_arm64.tar.gz"
      sha256 "e6be05a754ec530cdf7a175309dfb8f025872fd5e564b76cc1527612c754779f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1352/agentshield_0.2.1352_linux_amd64.tar.gz"
      sha256 "c097fb795b871111cc19bccff3c94f2c675b9a7bccf3ab9a2a4bbbecf4e244e9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1352/agentshield_0.2.1352_linux_arm64.tar.gz"
      sha256 "280b0924f8e865e92064afa172540a64f78bb83f47d650f5bec98a3bbc3e0360"
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
