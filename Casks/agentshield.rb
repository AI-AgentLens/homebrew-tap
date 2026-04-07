cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.463"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.463/agentshield_0.2.463_darwin_amd64.tar.gz"
      sha256 "0c6d71270f66cc6a5da28e4cdd77c6277a7475eac6d665ab9378905e675f47d7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.463/agentshield_0.2.463_darwin_arm64.tar.gz"
      sha256 "bbf1b232dd735c743abeda2cc3a8eba25fc752865b53c4cf1c74ea8fc5315739"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.463/agentshield_0.2.463_linux_amd64.tar.gz"
      sha256 "70f42d382beafc6121f530f06fbbc6e9bb40feaeac9f2c93cc3de12ebf16f712"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.463/agentshield_0.2.463_linux_arm64.tar.gz"
      sha256 "1e816672c710019db05b0c78268de0b17b7a0283265cf20548ab144faa912277"
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
