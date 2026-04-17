cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.630"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.630/agentshield_0.2.630_darwin_amd64.tar.gz"
      sha256 "6468e84d1238fc79530027d6d4b6f8d5b9d58c51af901bf47ecee3a07fb91a88"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.630/agentshield_0.2.630_darwin_arm64.tar.gz"
      sha256 "ce655df1eca9ba2e3b6918a6f05799682224d66813025b211c0d60ac0526492f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.630/agentshield_0.2.630_linux_amd64.tar.gz"
      sha256 "0b0ddcb61be1bdad2a0444eb56d18b963560ce0dcd6ea14278aecb7d42b62194"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.630/agentshield_0.2.630_linux_arm64.tar.gz"
      sha256 "04a5ae5cedeff69268d1292d119c99f8dd91e6db60848a958e71b6d6ab5761b5"
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
