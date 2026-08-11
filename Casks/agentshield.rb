cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1815"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1815/agentshield_0.2.1815_darwin_amd64.tar.gz"
      sha256 "238f239796259deeadfaf457302e0952fb3c36cf9e6367a55680ca4ce86b06cb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1815/agentshield_0.2.1815_darwin_arm64.tar.gz"
      sha256 "ebd30422bcef56aba2d7f1bc570f5ab6f375b8b6fa8f2d9a3c3be77594818fe4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1815/agentshield_0.2.1815_linux_amd64.tar.gz"
      sha256 "f487be5fdeb4561e5d0117b3bc8060a4cf1581c0e75645ea7f1efbe739193fcd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1815/agentshield_0.2.1815_linux_arm64.tar.gz"
      sha256 "75c8ba88203c2d4e598b5506288e8c1c50a2182d561ccab3370e543558c53d89"
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
