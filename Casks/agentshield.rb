cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.714"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.714/agentshield_0.2.714_darwin_amd64.tar.gz"
      sha256 "3a497ff8a2d816ded35372583d84b8d373ab5fec3111eead5db9a16a6e4213a2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.714/agentshield_0.2.714_darwin_arm64.tar.gz"
      sha256 "1c87cfa232fde5eeb5bf4bab1a45e8aab730625b907bd75ff2573e81d2b40449"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.714/agentshield_0.2.714_linux_amd64.tar.gz"
      sha256 "6d5ea5fd1293504f47240f0cee6b66853b8a465e25664aa283bdb2b27b0457fd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.714/agentshield_0.2.714_linux_arm64.tar.gz"
      sha256 "6c05f12d3fbf6a17d6b08c9d90554e2caf37763da0b836ed7315fa73ba12e194"
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
