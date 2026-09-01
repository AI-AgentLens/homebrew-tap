cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2013"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2013/agentshield_0.2.2013_darwin_amd64.tar.gz"
      sha256 "f366f00a98d0d9193b3817076cb9f4e9733f66cc25bae27bce36e4e4bc97e33d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2013/agentshield_0.2.2013_darwin_arm64.tar.gz"
      sha256 "8a54827cfe18c473cf1281d9d1d6cfe4a482fcf7c04ea93a7d85ef7942972b13"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2013/agentshield_0.2.2013_linux_amd64.tar.gz"
      sha256 "0ae80f49298f8e987a889ba4a3e988cdc885ce57ca55b199d4f26636de552848"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2013/agentshield_0.2.2013_linux_arm64.tar.gz"
      sha256 "888b8ddb57cece973f4dd48d24918543ad27c2ec9e501c329d40772925c906e8"
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
