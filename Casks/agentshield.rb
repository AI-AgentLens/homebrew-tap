cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1411"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1411/agentshield_0.2.1411_darwin_amd64.tar.gz"
      sha256 "dd0a28938066ae5998b5d7bd74a09b10fba217269c9efc824de3e0112421a59e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1411/agentshield_0.2.1411_darwin_arm64.tar.gz"
      sha256 "8a3a0fa5ff533838c09e66e89d2c708c38d77e24d76d82270b35271ceeae92cc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1411/agentshield_0.2.1411_linux_amd64.tar.gz"
      sha256 "ffdd1db926ae55ace3e865b2529e1f890331b09f2fd3a5eb1c19620899023216"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1411/agentshield_0.2.1411_linux_arm64.tar.gz"
      sha256 "69a427adf4c9e7e0052f70827d7a0c2d8915baa3ebd08e0d53e5a09a827c65d1"
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
