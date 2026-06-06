cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1228"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1228/agentshield_0.2.1228_darwin_amd64.tar.gz"
      sha256 "e660509a79d42027a47fde54efb5f72145050b33e626914f3da58e269aaca09d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1228/agentshield_0.2.1228_darwin_arm64.tar.gz"
      sha256 "ec8e44c173cd81dafeea0e1f643bec5ba8f5cd2717cc97d50c10c219a6b4c870"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1228/agentshield_0.2.1228_linux_amd64.tar.gz"
      sha256 "bd8ff40da67c92c3a5042fe71f8a22d563e8a6c5db889d5137de584baf6f22eb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1228/agentshield_0.2.1228_linux_arm64.tar.gz"
      sha256 "0b7ebcf2488e120ae32df67c1da39618a5826069388b54da3d9f6c1442dbda06"
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
