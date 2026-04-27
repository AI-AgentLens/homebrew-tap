cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.767"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.767/agentshield_0.2.767_darwin_amd64.tar.gz"
      sha256 "20bbaa83e5f3b03ee132c357036fc9f61e18aa5964f0c72cd0f32fbfe9b495fb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.767/agentshield_0.2.767_darwin_arm64.tar.gz"
      sha256 "e824e8a0e2c292ac1b1528db08945951767496948e9d9432172c2563ff88df3e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.767/agentshield_0.2.767_linux_amd64.tar.gz"
      sha256 "297461d931514679a49fd47779b5f9668b052d352c3f57014bc06dfa2f774ff8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.767/agentshield_0.2.767_linux_arm64.tar.gz"
      sha256 "a62fb821a9a883d4237f3bbf137ff7f59805a71522b0b33d68104fc06a4a4066"
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
