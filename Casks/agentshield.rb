cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.686"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.686/agentshield_0.2.686_darwin_amd64.tar.gz"
      sha256 "7a45c90c0f76da88440733d844774646b09bb168e917b13ebdf14171eab783c8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.686/agentshield_0.2.686_darwin_arm64.tar.gz"
      sha256 "717fc4c52682a3ce5034be0166d06678409ff411f19c4808258356882c1c5233"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.686/agentshield_0.2.686_linux_amd64.tar.gz"
      sha256 "4d6864a1d96696c25b0053153ad0e67af27d33018faf26126d072e4f6c13a319"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.686/agentshield_0.2.686_linux_arm64.tar.gz"
      sha256 "647d6ff2e41af10807e09278fe98f46d093511b6c162195adead9a33a30ed3e3"
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
