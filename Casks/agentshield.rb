cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1840"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1840/agentshield_0.2.1840_darwin_amd64.tar.gz"
      sha256 "440d1ca25e80b0f60a5429f8ddb65cb29a9ec3e2dcbd9723921be7eb8063fd24"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1840/agentshield_0.2.1840_darwin_arm64.tar.gz"
      sha256 "1285787670f0d320ebb1d12c965f636adbbf8c6ed7b91209fa922b58e8b50ab0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1840/agentshield_0.2.1840_linux_amd64.tar.gz"
      sha256 "66db7c0ea16c294914fde39d3f4067dcc43089863a04817de742dbfc06abf40e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1840/agentshield_0.2.1840_linux_arm64.tar.gz"
      sha256 "0e6d32b0421462d24098ee208482dfdb05d9d54a178d6284f93046d1dd310664"
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
