cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.696"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.696/agentshield_0.2.696_darwin_amd64.tar.gz"
      sha256 "515afd78533a7145cc6baea7f984a002f41ff78cc163d3bb443243859d1fec78"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.696/agentshield_0.2.696_darwin_arm64.tar.gz"
      sha256 "40c4977f42f1d982a7a742f0e90f5f82f39f9780c78310c1edf04ad33298e8a8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.696/agentshield_0.2.696_linux_amd64.tar.gz"
      sha256 "6a4d1ae1c086da6f612288453ba05c358b1ff714fd50e320a33780dd5696c047"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.696/agentshield_0.2.696_linux_arm64.tar.gz"
      sha256 "484c20efaed4185b97d9772d31f3c0dca8fc436dac764e776d4090bc014c0ff9"
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
