cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2284"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2284/agentshield_0.2.2284_darwin_amd64.tar.gz"
      sha256 "8c79acc15e13d02b7b599193a0cfec143994407980a5aa08a11859cf55c2ceb2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2284/agentshield_0.2.2284_darwin_arm64.tar.gz"
      sha256 "17c09aefa840d6bdc64125183a500f025f9ab5fdf9a95a95f88c64e0fba83751"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2284/agentshield_0.2.2284_linux_amd64.tar.gz"
      sha256 "3925062c4cf8e86dfa994d9aff1b118678745035330d20cf0e5322f4db24b976"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2284/agentshield_0.2.2284_linux_arm64.tar.gz"
      sha256 "6e6b1b2e9bcdd44f582c679397cbaaed23130174a0a4a9329fea928be05079d1"
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
