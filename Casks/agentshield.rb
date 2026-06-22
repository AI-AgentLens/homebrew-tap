cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1398"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1398/agentshield_0.2.1398_darwin_amd64.tar.gz"
      sha256 "a50281c1db93d25f92c54074c8ea353da39a4a0f0a4a9e9b1b3aad1969add4fb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1398/agentshield_0.2.1398_darwin_arm64.tar.gz"
      sha256 "0e2aaf57e1d9f59503f64d10cf2888219ebed7d773bfc75b63db6f79900b7a4f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1398/agentshield_0.2.1398_linux_amd64.tar.gz"
      sha256 "ec12bba923ac5e89e95284b0bbfebb6f81ce5d47313963d1369baf5a60ec16b1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1398/agentshield_0.2.1398_linux_arm64.tar.gz"
      sha256 "257e3e927c364c4153b9e2afd942b5897869d0031ad05d03e7b4440ae54aef57"
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
