cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2229"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2229/agentshield_0.2.2229_darwin_amd64.tar.gz"
      sha256 "7629671c143b15555ea611039deedd95f8ac37553ecf4adc531db979fdbcec77"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2229/agentshield_0.2.2229_darwin_arm64.tar.gz"
      sha256 "fc7d44f55c5a9d7a4fc2b8fcdf3f9e4e9b979837abccd02fc230bfc3c1713609"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2229/agentshield_0.2.2229_linux_amd64.tar.gz"
      sha256 "d2d530bd2603218e1c13990df84ca816db2ec98e93253103b45aa2e8abfd7743"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2229/agentshield_0.2.2229_linux_arm64.tar.gz"
      sha256 "d6b55dd8c89c1a8c85ad562e33b3d81f3432fb8a5d3c595e1f0a4b6731f91347"
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
