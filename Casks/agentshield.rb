cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.555"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.555/agentshield_0.2.555_darwin_amd64.tar.gz"
      sha256 "cd1f528ac6c7470472495a52fa56ed226feba8113f46f7764f8bcd8db92ff6bf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.555/agentshield_0.2.555_darwin_arm64.tar.gz"
      sha256 "b6d3866c36ba10b79777a6b2199b38c016102c0f5f5dde4af92d9769758fcaa4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.555/agentshield_0.2.555_linux_amd64.tar.gz"
      sha256 "502fc8c4f6e44755868dbcbf15ac0ef546c4d3dbf1a805b333f6979aae61b553"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.555/agentshield_0.2.555_linux_arm64.tar.gz"
      sha256 "9c354d8ca5d0cbcbf96a83f2e513176e90fe5866791e5b10da7ce4e69a21c11a"
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
