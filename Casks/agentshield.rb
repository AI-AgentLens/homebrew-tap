cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.796"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.796/agentshield_0.2.796_darwin_amd64.tar.gz"
      sha256 "45ac8c4b8840afc6efccd75cd479139d8d1ff09b945a34dba446b8f56d525d59"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.796/agentshield_0.2.796_darwin_arm64.tar.gz"
      sha256 "a6d90731eb01010705b97e09769aed90c086ade88ad52c6545ca9cf44ea8a485"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.796/agentshield_0.2.796_linux_amd64.tar.gz"
      sha256 "826ab48736bfb7d078e5353afe0425f6ba914a7367ac42b2371fd2147b976392"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.796/agentshield_0.2.796_linux_arm64.tar.gz"
      sha256 "0f90a24c254f5d87e4e655623f2307ddb4a4956c3b6d9497e3fc850fc2c0b1d7"
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
