cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.115"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.115/agentshield_0.2.115_darwin_amd64.tar.gz"
      sha256 "872a9e6e030f540c51cb4fd4c93b1b7fd1abb81ce012f6d0907b1e3a1cbe5ccd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.115/agentshield_0.2.115_darwin_arm64.tar.gz"
      sha256 "0660ac283037d0292ba657837fb12313b059d3a48c2fcfaed4204eaba92c5d31"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.115/agentshield_0.2.115_linux_amd64.tar.gz"
      sha256 "31327df3b53e82cf10d4415c6347fe83c52799eafab7347a9e2e62f4ebc12e80"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.115/agentshield_0.2.115_linux_arm64.tar.gz"
      sha256 "d56c66880f4d41bb3f564502ac5f25e286a1ee6413b06bee651ee3dd0f121757"
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
