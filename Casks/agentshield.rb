cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.308"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.308/agentshield_0.2.308_darwin_amd64.tar.gz"
      sha256 "c987ec5cc330ee19b76c8497c75e1b49d958d6fb474d3dff8350d3358e8652a0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.308/agentshield_0.2.308_darwin_arm64.tar.gz"
      sha256 "f0b654ca05aeabc6e7fcda7ce21b12d12b98a2ab6cb69799d2e4e5a7a6e645c0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.308/agentshield_0.2.308_linux_amd64.tar.gz"
      sha256 "d5fd1218d7a84e0d498c4c3cce8c91dfd80dc0cb61c1fa827a3a14bf2fea0fb3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.308/agentshield_0.2.308_linux_arm64.tar.gz"
      sha256 "6fa33e30075f1e582507b8fd07224226079aa4bde5b02dafa0712ef4f2ec8344"
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
