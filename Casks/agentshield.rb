cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1190"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1190/agentshield_0.2.1190_darwin_amd64.tar.gz"
      sha256 "b4bafa16f34ef9a07a04e88ad2292895dbd566685b7f1616bc3c52006e1c499a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1190/agentshield_0.2.1190_darwin_arm64.tar.gz"
      sha256 "e4b069ff0ccc05644c60fb5c59db6470672369f520f0a169d59975c970fe21a2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1190/agentshield_0.2.1190_linux_amd64.tar.gz"
      sha256 "ddd0a3423bab05f220ae03a112b1c502ceb9cebddf607636c2c8ad016fb801f8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1190/agentshield_0.2.1190_linux_arm64.tar.gz"
      sha256 "22a9c75162c48796b7193e0e08770b5fe5115d7450bd7dde6702812935ecfd86"
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
