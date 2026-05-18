cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1019"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1019/agentshield_0.2.1019_darwin_amd64.tar.gz"
      sha256 "3905935c96cc2e1b964186e0aab2f588848351bca6c6580e1030b24a48d51a19"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1019/agentshield_0.2.1019_darwin_arm64.tar.gz"
      sha256 "dd6e36c179721e3f93d4b2d0b66a4298823c5c2388d1beb248396bb423b4a32e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1019/agentshield_0.2.1019_linux_amd64.tar.gz"
      sha256 "ca25db66cf733b7585b8751528c08be13c2301a32aeb698cfe070760e95da2d3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1019/agentshield_0.2.1019_linux_arm64.tar.gz"
      sha256 "a7311ff795bc95ad90b506e69791bdee0f2fc77e2b392ca7c92445d32a1d718f"
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
