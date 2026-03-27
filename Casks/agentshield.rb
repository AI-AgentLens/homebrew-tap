cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.136"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.136/agentshield_0.2.136_darwin_amd64.tar.gz"
      sha256 "961287a40fe7220f8c55b8ace00e141e36e7df44866e1e62fb9656cfc7dc7897"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.136/agentshield_0.2.136_darwin_arm64.tar.gz"
      sha256 "dee68cf0a54abd7aa334495399154f9c8d817ecb6dd4ac67049fb2aeef0839f5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.136/agentshield_0.2.136_linux_amd64.tar.gz"
      sha256 "cd177ad8996a4409c7e76b1c32ad43bad486ef00ebe702dc7be69bd6f28959cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.136/agentshield_0.2.136_linux_arm64.tar.gz"
      sha256 "55d548a2de86758d040fe7768b4bef1ec2df82d7852ed5e3e04135813b6f5b9a"
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
