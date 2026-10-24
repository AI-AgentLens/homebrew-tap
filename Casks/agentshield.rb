cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2524"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2524/agentshield_0.2.2524_darwin_amd64.tar.gz"
      sha256 "b2d42af8035c84b586b0841ef1d80dd38ea60c12b1633292cf8271b0b2680ecc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2524/agentshield_0.2.2524_darwin_arm64.tar.gz"
      sha256 "b321a1ddd6cd220034243529a8a73df9ec9c0c2936abcd14215fdf4453c87cc3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2524/agentshield_0.2.2524_linux_amd64.tar.gz"
      sha256 "ea2fa2c8d33f679bdde26f150167d1faf777127f6a113cffa7dd94f9eccda0a8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2524/agentshield_0.2.2524_linux_arm64.tar.gz"
      sha256 "615782c0cb02b958f9695104c65382a4948b8772a359c57b8de0f8b1355d0f9d"
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
