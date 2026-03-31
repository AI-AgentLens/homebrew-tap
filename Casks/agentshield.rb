cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.271"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.271/agentshield_0.2.271_darwin_amd64.tar.gz"
      sha256 "03e73381a52cbbbb5998ae1d4a24fadf87f5e3662d34e9a64fcacc3b867991ca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.271/agentshield_0.2.271_darwin_arm64.tar.gz"
      sha256 "35571e108e09aa1444f39d092104e53f4c316fe18ee80f98cf3988d8c52444a7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.271/agentshield_0.2.271_linux_amd64.tar.gz"
      sha256 "594edaf57ed7022de36dc4b6b9a03435f30cb8a1a64ea1975d2e9e9c1a94ac77"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.271/agentshield_0.2.271_linux_arm64.tar.gz"
      sha256 "66b3fadf21aeb8fc7d8ffb0bf6e4cba4b95d526bb3e4b88a0ae4bfea400aecda"
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
