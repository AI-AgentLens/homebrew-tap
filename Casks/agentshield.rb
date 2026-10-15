cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2434"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2434/agentshield_0.2.2434_darwin_amd64.tar.gz"
      sha256 "5f069d42028eec1a3e66795b5c986a333b59bdb0afb9d97d97ba9d3c252ca34d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2434/agentshield_0.2.2434_darwin_arm64.tar.gz"
      sha256 "d74cd43650f2b66bb8f6979b20cb45b02614084a24899eb15ceea84ddaf8f642"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2434/agentshield_0.2.2434_linux_amd64.tar.gz"
      sha256 "45ed05ed56e0c4bdc83466ebac527d03ad40f2aff1758aec337f2d7275629a0b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2434/agentshield_0.2.2434_linux_arm64.tar.gz"
      sha256 "f19b68a0f613388756b25132ea4b75e698c5ad3c51a67d4a54b636d660f63726"
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
