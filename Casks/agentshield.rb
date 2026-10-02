cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2312"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2312/agentshield_0.2.2312_darwin_amd64.tar.gz"
      sha256 "f9f9589b5f7f1e7ad1d85b4191641be50f4b6e9e812c2c692d941e748c4894ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2312/agentshield_0.2.2312_darwin_arm64.tar.gz"
      sha256 "1d3eb12478bf1b0983cbe7c040f60c60056c2cace9587442aa443b56ee112b89"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2312/agentshield_0.2.2312_linux_amd64.tar.gz"
      sha256 "a834f2e2a743d75522e30dffef8570017178cb722eff4502d57bec2ccb75f448"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2312/agentshield_0.2.2312_linux_arm64.tar.gz"
      sha256 "698de4c6b779056eef871754e9db58921cbb909b11341160d8066d32ad8ba8f5"
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
