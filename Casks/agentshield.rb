cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1948"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1948/agentshield_0.2.1948_darwin_amd64.tar.gz"
      sha256 "630f8a4f06b372e680555a934d7a8cfb0066ee9335842858501c62919f31b28a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1948/agentshield_0.2.1948_darwin_arm64.tar.gz"
      sha256 "e79a4d2741638fbb6806f29edf438258f82945a949a59ea14aba006ba875e91b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1948/agentshield_0.2.1948_linux_amd64.tar.gz"
      sha256 "bee3d98bca6a8398b4e146d7b01ba4633d5dda44df655cf2f097fc2c8a1f710e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1948/agentshield_0.2.1948_linux_arm64.tar.gz"
      sha256 "d89f5d6576960de6b4fd6bca9b9b1cf9eb86cb2442da67a956e8c8a66d1bfa12"
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
