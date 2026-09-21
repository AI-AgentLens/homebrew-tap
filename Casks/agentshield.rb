cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2217"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2217/agentshield_0.2.2217_darwin_amd64.tar.gz"
      sha256 "7cd3618289e04de33a2619b3632221242da62bc8ce6723237616b05120e600df"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2217/agentshield_0.2.2217_darwin_arm64.tar.gz"
      sha256 "c904fad0c23882d2b1a22c86ad13ac8195993f39e9341ee21cb162cbe8c3b503"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2217/agentshield_0.2.2217_linux_amd64.tar.gz"
      sha256 "57902a5ef55d26a6847ebb8658b5512edf01084545660c61d27c95ea8018d1c1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2217/agentshield_0.2.2217_linux_arm64.tar.gz"
      sha256 "b7ad97dadf100c6de5be7e76b1fbc0ba45c73486ed63d73373167cc473db695f"
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
