cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1962"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1962/agentshield_0.2.1962_darwin_amd64.tar.gz"
      sha256 "86455741774523f3dd05c9c6565595856e53928ad4e10d34665193c038214860"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1962/agentshield_0.2.1962_darwin_arm64.tar.gz"
      sha256 "301c9d163020d9740f3ae8729fed3e939de4c3936209bb390ff19215125aec6d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1962/agentshield_0.2.1962_linux_amd64.tar.gz"
      sha256 "8f1b7cf417e7494c5761b128e02b1c3b1e9b9a5c475d6b492f66ae0e8043e16a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1962/agentshield_0.2.1962_linux_arm64.tar.gz"
      sha256 "0939a7e2058d26ea759c9551c97a303d52351e43ec5dd8d1fbf650fcb0e1f1c4"
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
