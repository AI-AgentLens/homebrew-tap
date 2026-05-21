cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1066"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1066/agentshield_0.2.1066_darwin_amd64.tar.gz"
      sha256 "98c1e4d804d8fa96a86a638389ac2213f1fb9a2c3b5a0ab114ab4f54722581dd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1066/agentshield_0.2.1066_darwin_arm64.tar.gz"
      sha256 "9239110fc3fc967aea8ce0bfee1de28877d012bb5e7b65478336077af54dc725"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1066/agentshield_0.2.1066_linux_amd64.tar.gz"
      sha256 "08179d6369370431125c1c51213213453e9877ad798ac1de3320897eb9c23650"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1066/agentshield_0.2.1066_linux_arm64.tar.gz"
      sha256 "5366d32f1438732fc27b35e3d5106a93c218abe9984886ece347dc0f9f757073"
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
