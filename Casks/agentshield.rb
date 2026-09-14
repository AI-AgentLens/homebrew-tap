cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2139"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2139/agentshield_0.2.2139_darwin_amd64.tar.gz"
      sha256 "a137379678bfca432d22fe4eeade1a80ce02ffdfe0aaeab779ed1c31a57966fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2139/agentshield_0.2.2139_darwin_arm64.tar.gz"
      sha256 "deb763df64b337a2ee5aa50ff6f3cf593af644b67725a95f1a028e94e012437d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2139/agentshield_0.2.2139_linux_amd64.tar.gz"
      sha256 "3c5d76a0279f73797da475c2d955ecf86d0d6ae42598b30b0f20183221be56ed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2139/agentshield_0.2.2139_linux_arm64.tar.gz"
      sha256 "da3cca6a04ce21f0b38efd27d446882f48feb65530ba144fca83a3c6bda3b8f8"
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
