cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.608"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.608/agentshield_0.2.608_darwin_amd64.tar.gz"
      sha256 "deabd911580a2127a516e62355eac2a30359c0c28681deaf6779e30772b53019"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.608/agentshield_0.2.608_darwin_arm64.tar.gz"
      sha256 "135df823cd18f8bce3a0560f7248f9b816872d0a574231a1cf280c295b85c5ce"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.608/agentshield_0.2.608_linux_amd64.tar.gz"
      sha256 "9ae632afdb8c13bce3416a6a95d25bc73d92a281fd7bdfb4c3f286759d0eb993"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.608/agentshield_0.2.608_linux_arm64.tar.gz"
      sha256 "9f388b519d8c1095d7483e2eec4265ccd1d37dbbad67b89fc1b28af90756f964"
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
