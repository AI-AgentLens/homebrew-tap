cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.477"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.477/agentshield_0.2.477_darwin_amd64.tar.gz"
      sha256 "c9c59279e69b77c7450f54fbf3a8cf4b8eabf3c4f7df8c4c9ac487f223a1b4e9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.477/agentshield_0.2.477_darwin_arm64.tar.gz"
      sha256 "f882217bd218b1fe7c8b97d3cbb35d6a2a144be2f749b56145b6007356840091"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.477/agentshield_0.2.477_linux_amd64.tar.gz"
      sha256 "19f83feb6fd52d00d68920a73c9bc024643881885181b3972938af2e2ee387e8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.477/agentshield_0.2.477_linux_arm64.tar.gz"
      sha256 "0ec62124261dabe27435115dbfebf4aed8c4229a7cd921c454ecc519a105395c"
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
