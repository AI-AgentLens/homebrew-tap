cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2075"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2075/agentshield_0.2.2075_darwin_amd64.tar.gz"
      sha256 "5f441a29b0fe9f9b373871e88e9a27c520bf4912db9f92057fc52d0eb3205ca8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2075/agentshield_0.2.2075_darwin_arm64.tar.gz"
      sha256 "588efff682e29e0b64d2c453d531be8655bb9472c3cbf901a71b64366f147b89"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2075/agentshield_0.2.2075_linux_amd64.tar.gz"
      sha256 "2a4a02aaa3c6e17122f8d71ab0eb721e73a5328a6dba881cbf8bba49ced9d898"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2075/agentshield_0.2.2075_linux_arm64.tar.gz"
      sha256 "d14f5d9f75b63ebd6efb4207d0eaf70701100af6e356edb16513200257b3ab63"
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
