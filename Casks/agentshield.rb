cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.603"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.603/agentshield_0.2.603_darwin_amd64.tar.gz"
      sha256 "d3b8fbe993dcae31868a995882ba14cdb9b77cd132a1b47c3cc864656e63eb09"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.603/agentshield_0.2.603_darwin_arm64.tar.gz"
      sha256 "ee976b80f0e15f4bd8793f49bdeb80b568122d24eacf663daf8a359db7b68f94"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.603/agentshield_0.2.603_linux_amd64.tar.gz"
      sha256 "166ed00da675026320d8b47e39e45c8ac744f0fde3997cfd5e4a12d809f1a425"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.603/agentshield_0.2.603_linux_arm64.tar.gz"
      sha256 "9eae1f869f0ef7c3a3bce076b5ed4ab40cafcb56930b98394db4c815698f6eb0"
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
