cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1681"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1681/agentshield_0.2.1681_darwin_amd64.tar.gz"
      sha256 "2670b9bf05d7cf89d769458c3ba50c60649bdbf6af88dbccf173583bd180d121"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1681/agentshield_0.2.1681_darwin_arm64.tar.gz"
      sha256 "78174fa371682f958a7bd6c52871f0425f8f0c6440674046b2488e6f27671bc6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1681/agentshield_0.2.1681_linux_amd64.tar.gz"
      sha256 "e80ecbe62a5ac17130b73f3a9109afdb6576a88f04ef3d28ecda1140b47efc1e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1681/agentshield_0.2.1681_linux_arm64.tar.gz"
      sha256 "bf8a0b831967a5722cfb0ef7da8fbe19d4fead0e4d1892226cbc6d367f1facdf"
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
