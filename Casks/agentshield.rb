cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.538"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.538/agentshield_0.2.538_darwin_amd64.tar.gz"
      sha256 "67dea69b0be7eaf124355badd2ffa974580adfa33bd7c418e1e43809ac821554"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.538/agentshield_0.2.538_darwin_arm64.tar.gz"
      sha256 "6a260e2580262f2c8050aab82d1e22d0d05533e864882d529bcdff35c2e12d5f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.538/agentshield_0.2.538_linux_amd64.tar.gz"
      sha256 "c50e799e2dd370d874e287d1eade7852ef730c57c135b187c8a23a50038ca6c0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.538/agentshield_0.2.538_linux_arm64.tar.gz"
      sha256 "3b9ce56f26c2068f918e4312755086501b716e02f2a2b92272ff241b21ee6e91"
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
