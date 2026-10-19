cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2473"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2473/agentshield_0.2.2473_darwin_amd64.tar.gz"
      sha256 "9ba40e3769bdf9d05c55fa173f7c6ca00ed1fcea8403154c545749c226ed81d9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2473/agentshield_0.2.2473_darwin_arm64.tar.gz"
      sha256 "f8246f8bdb437c49021b76b5820ebc1585b12febc7bf30079172061d351648c8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2473/agentshield_0.2.2473_linux_amd64.tar.gz"
      sha256 "a7f7f08a12729680fe0bd4e49af90b1305811da0394132c461ba0ef2641ec860"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2473/agentshield_0.2.2473_linux_arm64.tar.gz"
      sha256 "10abb74183da75660643f7b3bc4f4825e29340ee9d41a1cc8106292239679ae9"
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
