cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2146"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2146/agentshield_0.2.2146_darwin_amd64.tar.gz"
      sha256 "67dbb98ee13cd08f7ce52ed0aac94e9284e68029ee426ca952fb3ee7594ab232"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2146/agentshield_0.2.2146_darwin_arm64.tar.gz"
      sha256 "74f6c31196c93b170357e078f35c765c98efef38c17b3c828e66e4707cd6216e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2146/agentshield_0.2.2146_linux_amd64.tar.gz"
      sha256 "739d98b0b66acf6bc5bfd4e1f876021f65468e13a93ab2784a91daa1f1c7599b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2146/agentshield_0.2.2146_linux_arm64.tar.gz"
      sha256 "affa4a6a4a4dd2feedb7e1ad12acc898e739c0073388a9bce91f22f9410a9fa6"
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
