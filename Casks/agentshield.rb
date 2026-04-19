cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.651"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.651/agentshield_0.2.651_darwin_amd64.tar.gz"
      sha256 "63910c9e58fa6f836e5eeac283e648dfdfd122c15af17f03365f08f519bf258b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.651/agentshield_0.2.651_darwin_arm64.tar.gz"
      sha256 "5028508eb79537c138eb8a248dadcc41d3798a3462310dc5c23ee9db8bbe2bcb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.651/agentshield_0.2.651_linux_amd64.tar.gz"
      sha256 "689960621a4ac907821227ecf54197181dbeb0d24a71b0c519c06379a77ad154"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.651/agentshield_0.2.651_linux_arm64.tar.gz"
      sha256 "1b4641bfecc1c6542f8b06aa6c0f8f06c9b0e793a164928ac3fb878f8882cea0"
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
