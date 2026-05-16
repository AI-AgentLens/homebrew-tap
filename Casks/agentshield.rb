cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.999"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.999/agentshield_0.2.999_darwin_amd64.tar.gz"
      sha256 "2ceb411caa235bdf8fa65ad10990c1f082e66eb02492162713f4e6900d199fed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.999/agentshield_0.2.999_darwin_arm64.tar.gz"
      sha256 "da5b4d73ebcf73363f660128d18b36931c833debead57fdbb84c10d0f5ba551b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.999/agentshield_0.2.999_linux_amd64.tar.gz"
      sha256 "6bb92758a11367ca4af1a8d5f39926874528921f18999490b3e7810c39ff4a4d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.999/agentshield_0.2.999_linux_arm64.tar.gz"
      sha256 "106db63c6ed8c7dda84d1eabeae6bce2d7d2cd37799a17857c6bdd501502952e"
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
