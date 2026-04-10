cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.530"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.530/agentshield_0.2.530_darwin_amd64.tar.gz"
      sha256 "0b2e6f9ebc60b7c556c373c918a7bf76e9bc29b39039ad56d61866864bdf7781"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.530/agentshield_0.2.530_darwin_arm64.tar.gz"
      sha256 "e2d21619a356ae77dfe72234c23937713980b2e71129167c76b8f3ef298bbcc2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.530/agentshield_0.2.530_linux_amd64.tar.gz"
      sha256 "bc56c1df8db99b7ee96f525e9a01ec71751fc45e58d07f821c1f05b60db82fc4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.530/agentshield_0.2.530_linux_arm64.tar.gz"
      sha256 "1c5a79a2bf3a85e766d5db83bf32f27b0a335e6da177d0d0a71e995b1dc1fd2b"
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
