cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2189"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2189/agentshield_0.2.2189_darwin_amd64.tar.gz"
      sha256 "eeda7510eabf90697aec7465aeab1c87150ada6214b272d8adfd9306f9f91010"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2189/agentshield_0.2.2189_darwin_arm64.tar.gz"
      sha256 "e82b22e013d1e9f3a2873c996520be50641a2763d5e10f13f8b58520369a9b5a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2189/agentshield_0.2.2189_linux_amd64.tar.gz"
      sha256 "f4f99fa4c87b6f4f59a1dec81423c436b10dd38d75963c512d6bb94e61e986c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2189/agentshield_0.2.2189_linux_arm64.tar.gz"
      sha256 "0daf8db7e155f667b841873d99659e398f862c075f817b28b4be7da5896923dc"
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
