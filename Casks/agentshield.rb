cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1486"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1486/agentshield_0.2.1486_darwin_amd64.tar.gz"
      sha256 "a9f93eb8bca549dae9abeb409d625f7752f8985b0fa55294f627221971a1ed6c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1486/agentshield_0.2.1486_darwin_arm64.tar.gz"
      sha256 "83ae9fe54bee5321951541937f7c79b150ae33d3121189ed54222ed14e96af4b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1486/agentshield_0.2.1486_linux_amd64.tar.gz"
      sha256 "7b886c621f2174c9a852fddcbba729743430cfcc6f55d3ba0f092ebadce74473"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1486/agentshield_0.2.1486_linux_arm64.tar.gz"
      sha256 "e2a35556070d9134ce2acaf9dc49ba3a3fbaaa1fce4ef67cab1c982171df8157"
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
