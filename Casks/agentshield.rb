cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2130"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2130/agentshield_0.2.2130_darwin_amd64.tar.gz"
      sha256 "7023ecb417ed40d53b625df8a20aebde66298888e43253035648b592f9447c6b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2130/agentshield_0.2.2130_darwin_arm64.tar.gz"
      sha256 "e13d28d30001664285f73ad40ed4d67c266089bcd14e92cc23427e7ac31d0798"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2130/agentshield_0.2.2130_linux_amd64.tar.gz"
      sha256 "a87f6344f39816cdfbc6a6206bf25c131a8640a27561c1db0a6e31e9d9cbcf8e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2130/agentshield_0.2.2130_linux_arm64.tar.gz"
      sha256 "8799de2fc45da225dc58699423f1bbe2b61b072924f84ceed43bc9eb352a4a41"
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
