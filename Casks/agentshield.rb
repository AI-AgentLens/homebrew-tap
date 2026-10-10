cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2394"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2394/agentshield_0.2.2394_darwin_amd64.tar.gz"
      sha256 "efe41e706bd100f59f0229f700a276fcf22863fd77465f927025917bcb9ae3d2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2394/agentshield_0.2.2394_darwin_arm64.tar.gz"
      sha256 "99364f21e58f98047774cea2ccd36b50e868f55316c265c942dc3268e27b8923"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2394/agentshield_0.2.2394_linux_amd64.tar.gz"
      sha256 "79caa4b6ea98034359092aca9e0c05031a910e09c57cfa0b49cf687fa2beb9d9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2394/agentshield_0.2.2394_linux_arm64.tar.gz"
      sha256 "1ea9473d64a5bafbced097beae55d46bf9ec341db441661ad2ed639bae81bab0"
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
