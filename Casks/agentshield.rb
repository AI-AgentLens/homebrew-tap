cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2265"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2265/agentshield_0.2.2265_darwin_amd64.tar.gz"
      sha256 "50bf8b0e240848f2eb68b72b896b704e13d697d31c9dcaa30d3424cc4a3406b0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2265/agentshield_0.2.2265_darwin_arm64.tar.gz"
      sha256 "f2f9f19b0ccf5a4903ff60b4ac4e06a1074605cf21543ec1ff5e2845bff22a49"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2265/agentshield_0.2.2265_linux_amd64.tar.gz"
      sha256 "a7e9c247733d17b351ae7aedebd6161d4657ac35e1132d5b83064e0436b8becd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2265/agentshield_0.2.2265_linux_arm64.tar.gz"
      sha256 "b054404375228854f8c727c2c501ed935e415aa9b53c08abbfffe686ec2d771d"
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
