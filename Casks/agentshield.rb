cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.921"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.921/agentshield_0.2.921_darwin_amd64.tar.gz"
      sha256 "fcec124e736fdb5a43f83ce144200760c8eb9650a171593b0852fb26ec581e96"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.921/agentshield_0.2.921_darwin_arm64.tar.gz"
      sha256 "0b893b544d70447f9ac7735a333932d02fb55ff0065b5169f9e7cb9470fbce5f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.921/agentshield_0.2.921_linux_amd64.tar.gz"
      sha256 "389d6e5f91a87576684a7f2b6741f705b938ccd8dee9fba6be142b3f9fad63c8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.921/agentshield_0.2.921_linux_arm64.tar.gz"
      sha256 "3355d42b60195b3f3becc206ae3f7731b5675f79cbc67f604c592a43ed253970"
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
