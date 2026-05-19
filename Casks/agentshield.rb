cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1035"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1035/agentshield_0.2.1035_darwin_amd64.tar.gz"
      sha256 "bfa63739e44c795e10dc42f1b652efb061ac1e7fcb7798813ecf1dd1485c661f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1035/agentshield_0.2.1035_darwin_arm64.tar.gz"
      sha256 "fd2e7eab477ccf89bf4186dd43b120b8bd71c27893e84a9989bed395529e8288"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1035/agentshield_0.2.1035_linux_amd64.tar.gz"
      sha256 "cb407761fcb0c570242708217894f6f801433a5101b8a5d3b236145108a9597d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1035/agentshield_0.2.1035_linux_arm64.tar.gz"
      sha256 "c6e6eca35fc27ce5625e47f096a0b83688da2d662a188f2fa1fa4516cbfb251a"
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
