cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.808"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.808/agentshield_0.2.808_darwin_amd64.tar.gz"
      sha256 "56ffd84f6da142b3fe4af731e86d98f4a98fff320700e08a2b5f34eeeb65b531"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.808/agentshield_0.2.808_darwin_arm64.tar.gz"
      sha256 "820d33d869ebc16f7b294dce7120620d0a26b3323f853081f99fbc088af1bff5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.808/agentshield_0.2.808_linux_amd64.tar.gz"
      sha256 "035c4da541539feb65ac4020b0b0a8283e59f15e5644ebc98947437f426b3952"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.808/agentshield_0.2.808_linux_arm64.tar.gz"
      sha256 "d91d846e0bc523646cd7de5f70c2549897d6a2a2b5eb1b4e67a548d3ea26058c"
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
