cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1425"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1425/agentshield_0.2.1425_darwin_amd64.tar.gz"
      sha256 "6e75006f4c914dbf355f1d5a4df9071c94b6fa7e9b91d5c8aacef35434693f2e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1425/agentshield_0.2.1425_darwin_arm64.tar.gz"
      sha256 "ebdd93e48b8f7c00efab0a74fb42eaabbb662d618ed326bd48d46171e4073f53"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1425/agentshield_0.2.1425_linux_amd64.tar.gz"
      sha256 "581354c235b220962a09842d4b0827b13369e949390da521e705fb7727a0ea90"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1425/agentshield_0.2.1425_linux_arm64.tar.gz"
      sha256 "5047146f14b18effa18e09cc9fb06a873572d5d792bda4775ec4360b5b252132"
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
