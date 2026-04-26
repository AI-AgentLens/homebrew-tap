cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.743"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.743/agentshield_0.2.743_darwin_amd64.tar.gz"
      sha256 "a6268e4e6f5ca002f91d675192516bc4acdcd3935b1bf7e731adde6a89438757"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.743/agentshield_0.2.743_darwin_arm64.tar.gz"
      sha256 "4ff1560b83eb80862c207501f0fc8b39c3d9332f6360b0fb8230a5d1b8cab01b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.743/agentshield_0.2.743_linux_amd64.tar.gz"
      sha256 "9a37a4e475d4169720b5f566acbc6d2449f3bed3a672eeeafaa5baafa27f98cb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.743/agentshield_0.2.743_linux_arm64.tar.gz"
      sha256 "9eb084fe03da7045be03947db00d408cad8055ff96b1d1afb0a3232bec7428dd"
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
