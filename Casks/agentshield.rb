cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.543"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.543/agentshield_0.2.543_darwin_amd64.tar.gz"
      sha256 "1b6c5915c22bf9cf120b13e6ea654f3431b1ee340c8f15df4cf99bc3aa087ce0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.543/agentshield_0.2.543_darwin_arm64.tar.gz"
      sha256 "7cede0e6491375d8525bda27542d1583ac62b575e7edca408f1688664439ca84"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.543/agentshield_0.2.543_linux_amd64.tar.gz"
      sha256 "5712d41a33fca09fc49227e2d170189b7b67d8473c5943e7bd65a3d8da41b50e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.543/agentshield_0.2.543_linux_arm64.tar.gz"
      sha256 "4861f1afccdd4f33ec4fead7cae0a0f1e03029036e4a2cf89ab6e48e811d38c8"
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
