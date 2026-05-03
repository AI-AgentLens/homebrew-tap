cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.873"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.873/agentshield_0.2.873_darwin_amd64.tar.gz"
      sha256 "665b1c81619ecf6a70a76f7fa52924cee53a9d50a81b49434cc60e7b216eaac9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.873/agentshield_0.2.873_darwin_arm64.tar.gz"
      sha256 "eb6d07b842d1020746b3c8cb01a2374116f9a8d0270e25063ea6c1f2b2068d15"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.873/agentshield_0.2.873_linux_amd64.tar.gz"
      sha256 "859d033572bb4a0547eaee6d3f2dc9f577dba0178cf39a6e08e210961fdfa070"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.873/agentshield_0.2.873_linux_arm64.tar.gz"
      sha256 "4f2a000e20198278a14a8eba46e6433dc84857d54e58299c33e52f7cdd8bbb16"
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
