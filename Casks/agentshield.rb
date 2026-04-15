cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.599"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.599/agentshield_0.2.599_darwin_amd64.tar.gz"
      sha256 "1c53a949d7f6aa0ca5b10ab1e8cc8b8e64d846aaaaca3ea748a40fa0dafbf9b7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.599/agentshield_0.2.599_darwin_arm64.tar.gz"
      sha256 "15979a5423092ebc76714d5ccf41e13e693a425a083b1b48d9b7766e9c3ace00"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.599/agentshield_0.2.599_linux_amd64.tar.gz"
      sha256 "8326ee4585e80d7f49f116223478ce02dcabf5eb614e1d78a75d9e65f70a9b11"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.599/agentshield_0.2.599_linux_arm64.tar.gz"
      sha256 "35402edf95f1bea49b0f2707fcb7f2c0c883f05ee706a9f1a633ade81d7fde8a"
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
