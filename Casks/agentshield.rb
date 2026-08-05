cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1790"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1790/agentshield_0.2.1790_darwin_amd64.tar.gz"
      sha256 "8ded30846ffbe4e64bed48cba2734cfadde0aa3ede7f0c2a35fac75b295da201"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1790/agentshield_0.2.1790_darwin_arm64.tar.gz"
      sha256 "96befa0705be07b8109801decbf2443a9a70a4ae87526a6ba2f1edf575c4627b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1790/agentshield_0.2.1790_linux_amd64.tar.gz"
      sha256 "34729c2f4d7d7b0f961f78ef231ae4b2a429b82aec1ac1339ba81e1428013459"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1790/agentshield_0.2.1790_linux_arm64.tar.gz"
      sha256 "35b11693d5f31f4adbea4334c50ef2bb5fe983b5d767321f422b2aebb218a81a"
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
