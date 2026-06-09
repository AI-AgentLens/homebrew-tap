cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1267"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1267/agentshield_0.2.1267_darwin_amd64.tar.gz"
      sha256 "98b8ec54688ef297e4cdaadbe35461dcdeb18d3fca6e02d1bf7eca072f9dcb62"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1267/agentshield_0.2.1267_darwin_arm64.tar.gz"
      sha256 "e763df6a765623b1a3bdb57183504a44e2991ef77b13934bd11812ecebe86bc0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1267/agentshield_0.2.1267_linux_amd64.tar.gz"
      sha256 "a718938f394e408fc38ab09cc147c9448c6716cb2253323cc99c954b792cd98c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1267/agentshield_0.2.1267_linux_arm64.tar.gz"
      sha256 "6b5dac74c7335e7deac23c8b5c4d949f7b064ab948832bfeea62ce420c7af87d"
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
