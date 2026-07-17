cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1658"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1658/agentshield_0.2.1658_darwin_amd64.tar.gz"
      sha256 "87e1fb9a52a9cb5294701b78f1efb6d399816d010bfcd2b3011e4547fd6bcb0f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1658/agentshield_0.2.1658_darwin_arm64.tar.gz"
      sha256 "d9e55d1a541b8fe89437c7117335863ed61fb4fbd7a2980b6da280f651ec2db9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1658/agentshield_0.2.1658_linux_amd64.tar.gz"
      sha256 "b3a8128a5b8bfbcdb261ba42acb7ad03c19c7aacfd1e92a2cb9f3f66d05b2873"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1658/agentshield_0.2.1658_linux_arm64.tar.gz"
      sha256 "12bbe3e7ea3844a6c3fc8f9d177a86626841af4d6d142a3254c8cc8ec5662fd6"
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
