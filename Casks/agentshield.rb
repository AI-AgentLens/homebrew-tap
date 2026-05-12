cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.956"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.956/agentshield_0.2.956_darwin_amd64.tar.gz"
      sha256 "d1dacc548fc28089e758d85f3ec6f401638ed4f65108434f291a7ab9cd6c43ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.956/agentshield_0.2.956_darwin_arm64.tar.gz"
      sha256 "78f7a06afc286253cb7d0fc1ff90fee14dd63b325a978a7ac6792b18b42febe9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.956/agentshield_0.2.956_linux_amd64.tar.gz"
      sha256 "be151e6b0eeba78afbb213cd63bd710a28c017c4ad8aeda635257351753877d4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.956/agentshield_0.2.956_linux_arm64.tar.gz"
      sha256 "6e5045440fd2a6aa3f1bab9e673b46f748c82b89567961067c54de3b473793d2"
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
