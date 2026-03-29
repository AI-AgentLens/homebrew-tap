cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.203"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.203/agentshield_0.2.203_darwin_amd64.tar.gz"
      sha256 "086be3eb6dd5ba71612829644c3ace8748a9e2b6fed3ef4e29062a85cb07db3a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.203/agentshield_0.2.203_darwin_arm64.tar.gz"
      sha256 "c488b5144e613955851d3859cb941478d30ce426e7d1866b79d78a06de02dbcf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.203/agentshield_0.2.203_linux_amd64.tar.gz"
      sha256 "04d99e1ce4b3a0b9e20f470075d1bd19fd6d847b0c55e243ec7d3d508c78d66e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.203/agentshield_0.2.203_linux_arm64.tar.gz"
      sha256 "ff63269c9c9c444fd028fb571effd7e9121e0c7c375f4f50ffcc4a182a83a3ea"
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
