cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.334"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.334/agentshield_0.2.334_darwin_amd64.tar.gz"
      sha256 "594bbf0c3536acbaf3cc2054c784eb4f8198889fb19b0ff8543175affe80f913"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.334/agentshield_0.2.334_darwin_arm64.tar.gz"
      sha256 "ac6a92cb0c385b0da9352217274be2f380c308b0e0dd958b8040faa7c8d5081d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.334/agentshield_0.2.334_linux_amd64.tar.gz"
      sha256 "e8a659984ac582734c371f0e984c6895b759a2d0875fecf4bf40208fc0c79b0d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.334/agentshield_0.2.334_linux_arm64.tar.gz"
      sha256 "44e3657d4581f0c41f6491146b22ef4a01022052445fd6eef1369e0d40970907"
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
