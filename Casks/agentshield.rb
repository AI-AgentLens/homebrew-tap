cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.107"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.107/agentshield_0.2.107_darwin_amd64.tar.gz"
      sha256 "ecf9ae2d4a338f06f8a468a19fac0c0a33db4be05bc1834d13ec2c09326e120f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.107/agentshield_0.2.107_darwin_arm64.tar.gz"
      sha256 "24035319ae8d71a4eefe85246fefe888aa5d2d15d5f7e4ad97380ec8d427a121"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.107/agentshield_0.2.107_linux_amd64.tar.gz"
      sha256 "e9b3cc5d6edeeba7e6ca836a6b7b2e59df7ebe2fea21ae9acf1bd2ddc7ca3998"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.107/agentshield_0.2.107_linux_arm64.tar.gz"
      sha256 "5af3ac4b02d3e2e95d3c2dd8a5a6809e61c45103297c0c650b35098b4c5fe923"
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
