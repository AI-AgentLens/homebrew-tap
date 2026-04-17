cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.623"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.623/agentshield_0.2.623_darwin_amd64.tar.gz"
      sha256 "365634b97e030bf5e617198c1cf4ed0b36e953dbce0a29aa34464531f5d8cf67"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.623/agentshield_0.2.623_darwin_arm64.tar.gz"
      sha256 "1affae060dddd58ad4674b02a26c6f973e96d1c19833d5306c1e2cf68eb1e091"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.623/agentshield_0.2.623_linux_amd64.tar.gz"
      sha256 "1d0d2af85ceae4e0a86e2462657ed42b1fb339954a744abb1865a5b218d94d06"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.623/agentshield_0.2.623_linux_arm64.tar.gz"
      sha256 "459d7689a738f5016e7d9c539c3dd27b4b113b006f84562a9c47103f514ccc44"
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
