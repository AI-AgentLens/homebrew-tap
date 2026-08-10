cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1809"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1809/agentshield_0.2.1809_darwin_amd64.tar.gz"
      sha256 "3fd7299eb2ddef112f5d53b33680ea8508958fdde687cd69d129d59d82b91f57"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1809/agentshield_0.2.1809_darwin_arm64.tar.gz"
      sha256 "b3a9823b29e3d6101d641b77455a5f66b8ab3fb64a00194e31d362bdad6ad271"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1809/agentshield_0.2.1809_linux_amd64.tar.gz"
      sha256 "c7d9c176e833c3b0c7dcbfdbf5bfa639c510ec874c9e1bc2653b76e1cbe89741"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1809/agentshield_0.2.1809_linux_arm64.tar.gz"
      sha256 "7028492df1987574cae61a3047ece7fd104b0417f530002808ecc7ac3b577701"
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
