cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1629"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1629/agentshield_0.2.1629_darwin_amd64.tar.gz"
      sha256 "7e905af0dd8b292a1ba903c13e6d9e50ae6db26344ee40a1f31ba89a4ca6f666"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1629/agentshield_0.2.1629_darwin_arm64.tar.gz"
      sha256 "be6f5c1a9f3ff3be440924e06bb651e5d2fdb935f3f41c596861992f1e870891"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1629/agentshield_0.2.1629_linux_amd64.tar.gz"
      sha256 "1db3a6b54141b77ff05bf5b7a02e672f6c16fd6a4bc71e7fd56f9a0cd5e04f7b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1629/agentshield_0.2.1629_linux_arm64.tar.gz"
      sha256 "7832fa2302251010da10d7b718f5a3f1890ccf29de8e69bd914140f1cf8c107d"
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
