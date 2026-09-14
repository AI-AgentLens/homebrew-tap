cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2144"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2144/agentshield_0.2.2144_darwin_amd64.tar.gz"
      sha256 "55559cb6fb8a63468ced00b2350c99048a6c91ce78f23de1ccea13fdd5dbb943"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2144/agentshield_0.2.2144_darwin_arm64.tar.gz"
      sha256 "acdabbe0cba553a989cdbf2681c415c43b256dd94c213ff067384685205ed64e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2144/agentshield_0.2.2144_linux_amd64.tar.gz"
      sha256 "012e2d95b543f38f13829b46960a42121c7067683b7b1da0ae3cff0df4c8d562"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2144/agentshield_0.2.2144_linux_arm64.tar.gz"
      sha256 "abf6a1a975b84c12587109cd524810722a6dde065dcfd30944c5d49de720c581"
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
