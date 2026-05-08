cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.917"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.917/agentshield_0.2.917_darwin_amd64.tar.gz"
      sha256 "31a9dc2c0bf0231c9f7deabe3b845a7eec01d1fa5f6c35ba58b02780400b1be7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.917/agentshield_0.2.917_darwin_arm64.tar.gz"
      sha256 "9bcf5e0d28ae5c81c0145d008e19973c9bcf581c6396ea359cffb67457d91cb3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.917/agentshield_0.2.917_linux_amd64.tar.gz"
      sha256 "336d3c8c2fe57a97f4fee1c0136fde3128df82455f59ce10586275f0ad32a611"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.917/agentshield_0.2.917_linux_arm64.tar.gz"
      sha256 "01f6c159ad1df3992225a16e147344d43c9806b44cedfaeb521b2d8ac4d55672"
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
