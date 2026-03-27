cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.94"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.94/agentshield_0.2.94_darwin_amd64.tar.gz"
      sha256 "00715ac17a0bdc0f25bc905f4278efadda84240018bd23a53a34f65ed6f8079c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.94/agentshield_0.2.94_darwin_arm64.tar.gz"
      sha256 "866ca113563cd2aa10de3225549fc1bc97361635a16ccf42dde0bf1767419c7c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.94/agentshield_0.2.94_linux_amd64.tar.gz"
      sha256 "c008a64ea0d7076bfdf70427171e9e293818c5d9fbde5e9d301b59f35b97e08b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.94/agentshield_0.2.94_linux_arm64.tar.gz"
      sha256 "0ef1732d2c609388542bb6b610bbe40e06d29b0aafae50133feef66febb89e24"
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
