cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2190"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2190/agentshield_0.2.2190_darwin_amd64.tar.gz"
      sha256 "643689630af58dec9483695fcd84b5000cef645375f930ac67ecc8a75f8345cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2190/agentshield_0.2.2190_darwin_arm64.tar.gz"
      sha256 "394a0f02f50c72824d6418bda501d02d9ed683b9676a70c080c19ff4904ee031"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2190/agentshield_0.2.2190_linux_amd64.tar.gz"
      sha256 "62f2e4f14887e8be7ac0392a9e893a8b988cfc06d80d27a1830c2242e81302f1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2190/agentshield_0.2.2190_linux_arm64.tar.gz"
      sha256 "40af5ce20903e06f4acca42e0af1b3c34373f4efd41fa6b93b48f164a60ff177"
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
