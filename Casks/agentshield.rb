cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2052"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2052/agentshield_0.2.2052_darwin_amd64.tar.gz"
      sha256 "4672bc781bc7c104d8c688e295e78dfd1850579ce83e3de4e8ba3ac68131b992"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2052/agentshield_0.2.2052_darwin_arm64.tar.gz"
      sha256 "a9c72b2e0b3be59ad807d440de7b220a3dc35cacf9bb774258da535fc244a077"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2052/agentshield_0.2.2052_linux_amd64.tar.gz"
      sha256 "022122df2ec44f2e72061450ba31a5556adfe36e76cf722e092c6ada0ee1aeca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2052/agentshield_0.2.2052_linux_arm64.tar.gz"
      sha256 "e99b1fb6da5d34aba8ac7867dae8711ec7dc181e7a530ba696936b37d68bd7fa"
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
