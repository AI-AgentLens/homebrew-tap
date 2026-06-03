cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1200"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1200/agentshield_0.2.1200_darwin_amd64.tar.gz"
      sha256 "caac7301bbf88880e850b882aa0d14e5062534ee1b33b0829f0ae32aa675bd44"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1200/agentshield_0.2.1200_darwin_arm64.tar.gz"
      sha256 "96d27af6de7e570a2c133afe6deb18e28c6128b81602e8f75ebf25174042c99c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1200/agentshield_0.2.1200_linux_amd64.tar.gz"
      sha256 "6828a5b00bb39113e8bfcf18376548e8926d49a3ac5211aa5f863b42e9bb12a8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1200/agentshield_0.2.1200_linux_arm64.tar.gz"
      sha256 "1ccd0657365ee9d1ddaab7c3e7cf596d626bdcf5e27c4fe564d5bf135f7565e2"
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
