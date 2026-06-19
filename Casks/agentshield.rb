cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1374"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1374/agentshield_0.2.1374_darwin_amd64.tar.gz"
      sha256 "09f617fdd935333adee50cea0f09a58cd4f24a5bce900f26c63d11cc99561003"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1374/agentshield_0.2.1374_darwin_arm64.tar.gz"
      sha256 "636057163e215db0da5cfaac041aa08bec119cb9a53caeb29bebf1a606de6985"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1374/agentshield_0.2.1374_linux_amd64.tar.gz"
      sha256 "998bd3bdd3336f908ee25c3abdbe1676ed22ff5ada0d3b364a00256841132e70"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1374/agentshield_0.2.1374_linux_arm64.tar.gz"
      sha256 "a7602e39a25ff5615a2c07395489c7394329cd89c2c31f4616c6f2f0afc6ea25"
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
