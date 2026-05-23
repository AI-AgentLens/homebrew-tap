cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1090"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1090/agentshield_0.2.1090_darwin_amd64.tar.gz"
      sha256 "101159c0fbb5c48c9c8a6efb7eb08c5cefb8ba28ef5db236999ea682f69797d7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1090/agentshield_0.2.1090_darwin_arm64.tar.gz"
      sha256 "d4983d72575a5887f617d03fd041bdb1458b1d48995fcd3727cf0957d9075d86"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1090/agentshield_0.2.1090_linux_amd64.tar.gz"
      sha256 "565ed8fe3a63376a190b787a907b320f4dbe3a3c5ea0c550667707bbc3bed046"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1090/agentshield_0.2.1090_linux_arm64.tar.gz"
      sha256 "5610a7fd08b1a891608b1b667a0e97375ce14b821d9d5d5c60a443f18fdbc709"
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
