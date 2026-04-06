cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.428"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.428/agentshield_0.2.428_darwin_amd64.tar.gz"
      sha256 "992fecc150532b326d6d98e7e3a53bbbcd052b7399d819d73d90bcc82c92159d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.428/agentshield_0.2.428_darwin_arm64.tar.gz"
      sha256 "cf35d9492316beff69585fee79be406ced38995e5d7b1cf662ecf0d9235a6c55"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.428/agentshield_0.2.428_linux_amd64.tar.gz"
      sha256 "4ed1f1bb28aa65ac4078ccc55eed726808f1b7b4cf0d3c286ada215be458732b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.428/agentshield_0.2.428_linux_arm64.tar.gz"
      sha256 "b8b777fc406df8fe475b0d9f306d2d327d1fbbc3701cd17dfa43edff4d8149de"
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
