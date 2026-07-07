cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1575"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1575/agentshield_0.2.1575_darwin_amd64.tar.gz"
      sha256 "35908a15581b38b7589e43ad4771b07b151a7ed1de77ff334aeeda29ecbb3630"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1575/agentshield_0.2.1575_darwin_arm64.tar.gz"
      sha256 "1699f07f31e0738221e9286d741353bfcef6724b4b1deb6c9e64a661f288e0b7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1575/agentshield_0.2.1575_linux_amd64.tar.gz"
      sha256 "26ccb0b375493bffd2e67210b3d461b83cc2f7dae12706189f2033891ab4be30"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1575/agentshield_0.2.1575_linux_arm64.tar.gz"
      sha256 "ec174e43914bc1f68b4dd7552a1a83959167a0ab81547ad9c7a77e2a97d474c2"
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
