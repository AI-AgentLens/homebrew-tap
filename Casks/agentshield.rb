cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2278"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2278/agentshield_0.2.2278_darwin_amd64.tar.gz"
      sha256 "48e0b3b53ea26d53829ffa75fe3961cb5649cb594fac83b68c50ae282f674ec6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2278/agentshield_0.2.2278_darwin_arm64.tar.gz"
      sha256 "1e6fd8851dd7d3beaa5eb79bfc8f496cb9e7e99733912d70f66ada7df1ab111a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2278/agentshield_0.2.2278_linux_amd64.tar.gz"
      sha256 "aaa219881ad45c1dbb72780026d777ded1229b16cf76234e39d5f3a5082ced5f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2278/agentshield_0.2.2278_linux_arm64.tar.gz"
      sha256 "16e36c39457ec2e9a273deade3ab769c902b84ae42dc57d64b79de111e7d80d1"
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
