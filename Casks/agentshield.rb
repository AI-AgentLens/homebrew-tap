cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1680"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1680/agentshield_0.2.1680_darwin_amd64.tar.gz"
      sha256 "a9d9de3d7253ae758f6005fcdcdac4dad6f93fb0c32b9834e9e87e15dcaee73b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1680/agentshield_0.2.1680_darwin_arm64.tar.gz"
      sha256 "5ae6c4f0872875409c5b3cd5cf708bca77b4b4452963d92058e58985ac399e77"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1680/agentshield_0.2.1680_linux_amd64.tar.gz"
      sha256 "46ae104e9b7ec5e30151e47c3fc24455888c10a08670bb7b96270357724d4a81"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1680/agentshield_0.2.1680_linux_arm64.tar.gz"
      sha256 "97973581fcf29e5caae0a2c28b2d8d7789e697fa17d256820edc1f31f976824d"
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
