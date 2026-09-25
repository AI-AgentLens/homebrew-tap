cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2255"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2255/agentshield_0.2.2255_darwin_amd64.tar.gz"
      sha256 "c22843e13296e2260d5b74dff06d0d829c33ecdf7c71524781f6fefd3a748824"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2255/agentshield_0.2.2255_darwin_arm64.tar.gz"
      sha256 "56297a13ec6a0eb30c297e85d56332274a7740d0233663a97b5d011e639517f4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2255/agentshield_0.2.2255_linux_amd64.tar.gz"
      sha256 "fcde11dfcd85d37dbb2c8abb73bf7585b46bad135021dc8f48068892d0522d0d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2255/agentshield_0.2.2255_linux_arm64.tar.gz"
      sha256 "9a037c1ba29a98d6f3df6147c5c3a5319267d502428d003e88f9df976f13228c"
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
