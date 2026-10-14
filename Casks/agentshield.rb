cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2428"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2428/agentshield_0.2.2428_darwin_amd64.tar.gz"
      sha256 "c1df911713407103c70abf227b7f45dbd63a973527a21842633f9fbc1e6d7aa2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2428/agentshield_0.2.2428_darwin_arm64.tar.gz"
      sha256 "eb6cdb367943959c7a0b64b60c28fecc747f3d50c927163d0748042dde673b95"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2428/agentshield_0.2.2428_linux_amd64.tar.gz"
      sha256 "97b503acc45ba3c077d30ead45a4e7194cc619f15be86aac15d65e2ded947ec3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2428/agentshield_0.2.2428_linux_arm64.tar.gz"
      sha256 "94cf58ef28192d57177de12d5f7b2fde7d9b8779acb8b562a34a97c8895800d9"
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
