cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.507"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.507/agentshield_0.2.507_darwin_amd64.tar.gz"
      sha256 "61f7d0f58deb05baf129aa61b4eb416d88ef8cd13dff513f4054d444d7afb788"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.507/agentshield_0.2.507_darwin_arm64.tar.gz"
      sha256 "50230865c9dea80576ab8f82d4973dd4efd14eb4a5ee75ff11229cb7e3eda576"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.507/agentshield_0.2.507_linux_amd64.tar.gz"
      sha256 "1965e319ee4737c930d85002e5559c6e56d2a959918e21bf09922f34c4ed64d8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.507/agentshield_0.2.507_linux_arm64.tar.gz"
      sha256 "3ed3ebd30c95af0d06718856081394ac92114a4ab00c1f59e349e1a53ab3ebbc"
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
