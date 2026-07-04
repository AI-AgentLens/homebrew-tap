cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1550"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1550/agentshield_0.2.1550_darwin_amd64.tar.gz"
      sha256 "f12c24024318be5d16b40cd8967ee11da7c348e3d40f2cd0e98ff9ba9ae11fce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1550/agentshield_0.2.1550_darwin_arm64.tar.gz"
      sha256 "8fcc039556cee107c3eb3552e235030f09b7ae1ed7400ca17c648e563798f884"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1550/agentshield_0.2.1550_linux_amd64.tar.gz"
      sha256 "7c7262210ec1cf50b4540448f1c4fdbed102a7012439cf14bd0d02ed2bef9fc5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1550/agentshield_0.2.1550_linux_arm64.tar.gz"
      sha256 "e3c406fb6a929eb589b42b52dd9c8ec1a08de2cf4d1a17b1730ba678505c9197"
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
