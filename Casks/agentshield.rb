cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1793"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1793/agentshield_0.2.1793_darwin_amd64.tar.gz"
      sha256 "9586eb3c27dbb3be892f9720d84858a7a874606fd668cbbe6294dcdcb2471ca6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1793/agentshield_0.2.1793_darwin_arm64.tar.gz"
      sha256 "c8b1f19dfa5c1e9220f821682472a13740371b3eb75595eb3f24e6c4612474cd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1793/agentshield_0.2.1793_linux_amd64.tar.gz"
      sha256 "3d3a0b2486fcd7f1e4215e8fc74b1908f395552d62cd135322e3b8e433b4c0a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1793/agentshield_0.2.1793_linux_arm64.tar.gz"
      sha256 "f5aed1d61b32d7e8b7fac4abd306c93ce22b90414edfbae81aea87b34a407501"
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
