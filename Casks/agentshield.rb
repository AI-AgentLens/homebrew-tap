cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1744"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1744/agentshield_0.2.1744_darwin_amd64.tar.gz"
      sha256 "b1fcaa51c2bad856c3117de0b130f01bbdae1d4ebeba979dd0b128c1bd819ae9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1744/agentshield_0.2.1744_darwin_arm64.tar.gz"
      sha256 "e0018caf066b993e605785f9589fa110d99abcc57d255fc7ff98619f41b874b2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1744/agentshield_0.2.1744_linux_amd64.tar.gz"
      sha256 "93f20dc349e50d194935ce090f399a3f2d634f14b8d97aeb019577dc97233674"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1744/agentshield_0.2.1744_linux_arm64.tar.gz"
      sha256 "a91855f752c654cfd15cc44b66dfbd81c52ae5faade8f2a0003e9ad698e4d91c"
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
