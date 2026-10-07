cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2364"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2364/agentshield_0.2.2364_darwin_amd64.tar.gz"
      sha256 "e9732c385a9d750cec1f1e6ed7ac9826bb0f6891e158991b3174fec638b6f90e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2364/agentshield_0.2.2364_darwin_arm64.tar.gz"
      sha256 "41b552fb303b8a8579c5e9698d5f080b498a4d3a1cc3e1ef07eae208176acd28"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2364/agentshield_0.2.2364_linux_amd64.tar.gz"
      sha256 "9eda8498aea380b074f196cb74c79746e872ec37ea9aa92ebfddd9e0c0cba375"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2364/agentshield_0.2.2364_linux_arm64.tar.gz"
      sha256 "df7be28b8cf15ebfc20e85b32487a562b2128dd9a27cbaf4ae20ef6b5461cefc"
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
