cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1433"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1433/agentshield_0.2.1433_darwin_amd64.tar.gz"
      sha256 "31098fe0a11c26fbe06028a584a0516ceb890c8582e9f5f17d7c81af6bf5c013"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1433/agentshield_0.2.1433_darwin_arm64.tar.gz"
      sha256 "87126b10e8fd88ca65e8b9806da0c7e69582ba1192653f853411f5131b668178"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1433/agentshield_0.2.1433_linux_amd64.tar.gz"
      sha256 "36629378e2204591cd5776f14d927b48dde7c95fe48aa5809edff1cd74645923"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1433/agentshield_0.2.1433_linux_arm64.tar.gz"
      sha256 "5e25562ee2f79e7e61c0a5a4220f48fa0242900ad960eb75e5c98cd5385de6a8"
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
