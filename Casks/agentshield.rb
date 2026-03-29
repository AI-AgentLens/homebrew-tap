cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.211"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.211/agentshield_0.2.211_darwin_amd64.tar.gz"
      sha256 "3300c4d7af42df404913d262cea7ce452cde52ddb737ecd651c6e069e05300fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.211/agentshield_0.2.211_darwin_arm64.tar.gz"
      sha256 "5e9dc068c60d3f1a58b76fdcf4da9c5be93df50a72867f4405951a78aa08bbca"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.211/agentshield_0.2.211_linux_amd64.tar.gz"
      sha256 "312f221aa0b7bd37874abc7f0c36efacd69f2f9ce8ea960e4e4efac51d2e052d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.211/agentshield_0.2.211_linux_arm64.tar.gz"
      sha256 "78692df85366727a9952123df07fdf1f5d7544d009ef2e7973308a3e38c732a3"
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
