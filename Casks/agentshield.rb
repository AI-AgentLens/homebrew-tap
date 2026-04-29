cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.806"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.806/agentshield_0.2.806_darwin_amd64.tar.gz"
      sha256 "ca8a0eae7895a35d3f2f058038430f26eb70e65115862a7172c0476369873492"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.806/agentshield_0.2.806_darwin_arm64.tar.gz"
      sha256 "7e19b373624009d4c0d2bb31474d7da558172d082c0ddffa3ba5c7ea9545215a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.806/agentshield_0.2.806_linux_amd64.tar.gz"
      sha256 "c2ffac4df2cebaac8e97c799e865faa58f5565f923237fad625d2f87479c33b2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.806/agentshield_0.2.806_linux_arm64.tar.gz"
      sha256 "9fd77e1de86ac7a2a0abbcb4889b2d91e6b85598bb00c6445866926a0ea996a9"
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
