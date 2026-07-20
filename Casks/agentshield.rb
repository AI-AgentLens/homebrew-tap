cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1683"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1683/agentshield_0.2.1683_darwin_amd64.tar.gz"
      sha256 "84704a29538ee12fe0cc99332aa3eea158ae181157f7819b7e91cc286ede66ce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1683/agentshield_0.2.1683_darwin_arm64.tar.gz"
      sha256 "e82008340dc45481b014c5acca8824f514fd5a66b7509c3f4de1652393cb0500"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1683/agentshield_0.2.1683_linux_amd64.tar.gz"
      sha256 "887a2229b3178b70e82b59ed22140a27d5353d6a737e37598225f81bb94cfd82"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1683/agentshield_0.2.1683_linux_arm64.tar.gz"
      sha256 "9651880d8af8db53bb95c0b9c99a9286d2d2c5e723ed9bcd0acd0d7d422bc0c4"
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
