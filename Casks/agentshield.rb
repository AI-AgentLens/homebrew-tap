cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2280"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2280/agentshield_0.2.2280_darwin_amd64.tar.gz"
      sha256 "0c491b0f765c68e7c07f554f4d5d44a59a3af52e6e25757c19fc1520e7933cdc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2280/agentshield_0.2.2280_darwin_arm64.tar.gz"
      sha256 "7fcd1464f85dc2f9ce4c016af3285e6dbf4e39cf60c613c047babfd8a15ecd42"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2280/agentshield_0.2.2280_linux_amd64.tar.gz"
      sha256 "9990fa15a63a9a72ab4174086c63fc7d8180cebb11f6c60d47e5bae7bccf71c2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2280/agentshield_0.2.2280_linux_arm64.tar.gz"
      sha256 "5d03e5bff21774f5d51242b6610ed71241dfc0b61e853a50648992361567ab4f"
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
