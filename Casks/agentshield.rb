cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.661"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.661/agentshield_0.2.661_darwin_amd64.tar.gz"
      sha256 "bf3a5f0070d4c83b2e8cefe8aafca3655eb13ccdf8f74f8de5dd14b31f89a4c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.661/agentshield_0.2.661_darwin_arm64.tar.gz"
      sha256 "0799a282d3818d63939770304a10b5476c86bae0002fd2d9bda289512b7236ea"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.661/agentshield_0.2.661_linux_amd64.tar.gz"
      sha256 "22f53b53b86bc34a87905992ab66c0cf636924beee55f548ac8adbfcad32d14a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.661/agentshield_0.2.661_linux_arm64.tar.gz"
      sha256 "a36e13314529226339c536fbdc192e6900ac7cc2d9ced07e176fb03de9621603"
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
