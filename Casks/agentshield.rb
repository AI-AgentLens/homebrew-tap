cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1566"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1566/agentshield_0.2.1566_darwin_amd64.tar.gz"
      sha256 "2766542f56000faaa34f9db4819733d28f07797681b347262bed75bd0a012ef0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1566/agentshield_0.2.1566_darwin_arm64.tar.gz"
      sha256 "73dc5b71220601ede6d6f1f516a1590da02256668502a3a93791919eceaa1be4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1566/agentshield_0.2.1566_linux_amd64.tar.gz"
      sha256 "4242e28d7fb1ac349315c23d665c2491192106137c80cec0eac62afd59ddf109"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1566/agentshield_0.2.1566_linux_arm64.tar.gz"
      sha256 "2dbd4ee6f009acf22ff8e73b828b02195854610a92bbe95cbe90489376537905"
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
