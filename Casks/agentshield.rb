cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1394"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1394/agentshield_0.2.1394_darwin_amd64.tar.gz"
      sha256 "fdaf0b351d6467adfcbe733494aa7fc4ec810053c980808f1de43bf3ded369a5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1394/agentshield_0.2.1394_darwin_arm64.tar.gz"
      sha256 "0ad4d75f6f9d89881422c4ac84a88766a51e9e30bf486ebd7939ad8243b25250"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1394/agentshield_0.2.1394_linux_amd64.tar.gz"
      sha256 "953fe3a9583f3e232e90da909ab486111211ef8ad689bc00ef0b6fd18ebe7745"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1394/agentshield_0.2.1394_linux_arm64.tar.gz"
      sha256 "33344af49d221c6259f346bbf387e765c68dc1c9932e2e9e0f29974df7e9e57d"
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
