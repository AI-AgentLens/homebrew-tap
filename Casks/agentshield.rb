cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1476"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1476/agentshield_0.2.1476_darwin_amd64.tar.gz"
      sha256 "be90e8d841aba63f68f44341e402ca7a599fe2b743ae8249e7d7845dcb9c11f0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1476/agentshield_0.2.1476_darwin_arm64.tar.gz"
      sha256 "fc46ddc6cc48b091edaf4c13c57c8ff8ce25466295c974c386cfbcff8faf9705"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1476/agentshield_0.2.1476_linux_amd64.tar.gz"
      sha256 "28610643eec013b24b1bc5e562e1f00e146dd7b6493d9b86626104a7e22683a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1476/agentshield_0.2.1476_linux_arm64.tar.gz"
      sha256 "f2cd289c11d0edd8eb38f939d380d07d44481a0a5f01bb11862957cd9d8c3659"
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
