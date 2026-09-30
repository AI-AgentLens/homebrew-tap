cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2295"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2295/agentshield_0.2.2295_darwin_amd64.tar.gz"
      sha256 "7d20e6de96e6cc966cb2cabc3e829eb8e0dc5556b04a3beece2c4abf9cdc7a64"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2295/agentshield_0.2.2295_darwin_arm64.tar.gz"
      sha256 "dc4e80a14abc1aea80e693663c8c994d9140818a86c11334fe0156534304183a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2295/agentshield_0.2.2295_linux_amd64.tar.gz"
      sha256 "f483ef643a221fc78d055603feca724eb93a788e9a53d03bd166a8525cc2dc6c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2295/agentshield_0.2.2295_linux_arm64.tar.gz"
      sha256 "59b113f9699a5852ecc98bf1df10f652ba806c950f73e8dfad243cacf14ab850"
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
