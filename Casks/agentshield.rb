cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.602"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.602/agentshield_0.2.602_darwin_amd64.tar.gz"
      sha256 "2c4bf84f2506ebe61fb5b52314110303014c432846e1fa74404ce4a209ef82aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.602/agentshield_0.2.602_darwin_arm64.tar.gz"
      sha256 "c82880c98f393804babae74a20d5330039178e021615711493fbee314c003822"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.602/agentshield_0.2.602_linux_amd64.tar.gz"
      sha256 "d58fdf383ad739fc24c9ffc55468ff9a7d4f80a0efc253df95972c130d2b173e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.602/agentshield_0.2.602_linux_arm64.tar.gz"
      sha256 "0831d65099a748094615449d23e09cbb407a508ab2c0f94d96460a77a68a9067"
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
