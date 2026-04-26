cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.748"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.748/agentshield_0.2.748_darwin_amd64.tar.gz"
      sha256 "3cc5ff02cc93f6ca223893d50ffcb060a8f0024838a5f9bb36ac780688aea415"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.748/agentshield_0.2.748_darwin_arm64.tar.gz"
      sha256 "5c35091c892d22df2f299464c306ee99992287f2021d6217621a1f38090358d8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.748/agentshield_0.2.748_linux_amd64.tar.gz"
      sha256 "a4db7d55a09804b2185dbf4642597272af86e66bac5b86d2d4a06e33ff0f5c17"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.748/agentshield_0.2.748_linux_arm64.tar.gz"
      sha256 "e854aef1f69e19d067d17654661c984a3a7ca4e1447ec322e843947e4b9e9881"
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
