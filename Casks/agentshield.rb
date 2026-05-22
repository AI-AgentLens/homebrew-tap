cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1085"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1085/agentshield_0.2.1085_darwin_amd64.tar.gz"
      sha256 "52753e8a8591e4907652aea4488f16c55c451d85b48e8d714c70f37299a0e03f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1085/agentshield_0.2.1085_darwin_arm64.tar.gz"
      sha256 "26dea54c5e7d61c14cdd843e87a61b18c13a263d9224ac366aed3b6e06222d3d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1085/agentshield_0.2.1085_linux_amd64.tar.gz"
      sha256 "395d9bf779f552b4762fb7a9893422822f5a6f92fe3ea77cecd9a161a25ba64a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1085/agentshield_0.2.1085_linux_arm64.tar.gz"
      sha256 "36b374b7453b54bafd1796d56f0f8e006f1d6330f45d62145f6f3c10bd29ebe4"
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
