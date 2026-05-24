cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1117"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1117/agentshield_0.2.1117_darwin_amd64.tar.gz"
      sha256 "2a7b8cc2207f79fb5899a18938d5539a0752ef12f3d46f9a9285a57ffc4a7f9c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1117/agentshield_0.2.1117_darwin_arm64.tar.gz"
      sha256 "e5dd2f3c68f6da5e7c9d9bcf1437a140b25f57cdfdd782f1d298c27c9c9e68ff"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1117/agentshield_0.2.1117_linux_amd64.tar.gz"
      sha256 "d95e139ddec2c97d8d01a36cc6fffe93d4365bffca2c6d35d9d0d14eba49af20"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1117/agentshield_0.2.1117_linux_arm64.tar.gz"
      sha256 "19625e9f7cd407c3d397f5d023fe12c474f0afc3861d030aec808fd9e2b89a36"
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
