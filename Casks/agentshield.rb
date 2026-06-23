cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1412"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1412/agentshield_0.2.1412_darwin_amd64.tar.gz"
      sha256 "41345963272e4cdcc44a9c6267f4ea2659a0fba87de2496ecf623a0d41332ae6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1412/agentshield_0.2.1412_darwin_arm64.tar.gz"
      sha256 "a70187d8ae4c988c5a5ffb084d247dc1923e56f39f60523c1fef68f25ea60aa9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1412/agentshield_0.2.1412_linux_amd64.tar.gz"
      sha256 "328a93710fef4ecee72a569c5237bcd93a5b8267dfff4ed9d401d1aa772eea9a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1412/agentshield_0.2.1412_linux_arm64.tar.gz"
      sha256 "f602d3b036170ff2f53f42d03d6e4db6692028ab2f830a76b62350e376aaa454"
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
