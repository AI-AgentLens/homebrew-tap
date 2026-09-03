cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2031"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2031/agentshield_0.2.2031_darwin_amd64.tar.gz"
      sha256 "d4d15722dab2e573e2e5e10b300a03246881823fe826dce09f670332d959f1e9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2031/agentshield_0.2.2031_darwin_arm64.tar.gz"
      sha256 "602d74c285e048e5a3c4567d922e566e176510a7979ca317371f8547eb285c07"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2031/agentshield_0.2.2031_linux_amd64.tar.gz"
      sha256 "05f8e0ccf24d45a97366569a0520c151639caf5baf4e8adc33063626c1cc086b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2031/agentshield_0.2.2031_linux_arm64.tar.gz"
      sha256 "9311215b7478245eedd7de1a7cea0820bcc149537e63237d03e0172ee888709d"
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
