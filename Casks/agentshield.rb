cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1535"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1535/agentshield_0.2.1535_darwin_amd64.tar.gz"
      sha256 "2992de8f16207c27dbddd7090128e85792ea2571c0115864a6e2f2440f4bef0f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1535/agentshield_0.2.1535_darwin_arm64.tar.gz"
      sha256 "1a72e3379576e886bdacdd2e0f6b88808a755ecf63fce9b272e198efa93a9a1f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1535/agentshield_0.2.1535_linux_amd64.tar.gz"
      sha256 "5f2fb6a1213d327006500d2c47812fc8223ba6cd5547a0c387b34cb9d7a17628"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1535/agentshield_0.2.1535_linux_arm64.tar.gz"
      sha256 "fd637d0b20f86aec82184e8023e08948bcaf3c473dccce58562df0cdf98e9228"
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
