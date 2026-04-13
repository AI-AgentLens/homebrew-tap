cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.569"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.569/agentshield_0.2.569_darwin_amd64.tar.gz"
      sha256 "bec7f7f1593948b72a0605ccfed670fa852fb77c3acf45987cbe537befe6bdab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.569/agentshield_0.2.569_darwin_arm64.tar.gz"
      sha256 "8da359001680ba0e2922fb706e4b518516cab64f0c1a00c16282e210e304609b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.569/agentshield_0.2.569_linux_amd64.tar.gz"
      sha256 "da32c36a1503fdfebf177899c8cc05d314afca40c22be6f3023ad98174f7f3a2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.569/agentshield_0.2.569_linux_arm64.tar.gz"
      sha256 "ef1ff95ef9f3bce907ec7bdbf23a23a8b21f5a3e2ce359cba236ccbde279ff34"
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
