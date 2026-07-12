cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1624"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1624/agentshield_0.2.1624_darwin_amd64.tar.gz"
      sha256 "1ada8f355b6bc7849526758344f6af7f2cd7b68860cdb8123b67e1d697c47fe5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1624/agentshield_0.2.1624_darwin_arm64.tar.gz"
      sha256 "d0c0ca8861501c467896ed1bb8d9a70b4eca72353cb22225ad95786d3bfc480d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1624/agentshield_0.2.1624_linux_amd64.tar.gz"
      sha256 "8c524de53ccc831426d03b9d0b5da0eb7ee8d048cafbecffd7842e024ec11347"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1624/agentshield_0.2.1624_linux_arm64.tar.gz"
      sha256 "5e84a6c9f37ee6447151cd4d66a02b689f5b232286aeca32cf4923bed4fe66c5"
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
