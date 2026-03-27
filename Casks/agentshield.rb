cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.114"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.114/agentshield_0.2.114_darwin_amd64.tar.gz"
      sha256 "e082c000bb15765d7c46b61f251ef0bcb023dd10f5e56eacf376a18a71d01d66"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.114/agentshield_0.2.114_darwin_arm64.tar.gz"
      sha256 "b7baf8eeb44c54f3ebae08ca7a9914c37c41a3c96fd3a626615aef556f7de57c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.114/agentshield_0.2.114_linux_amd64.tar.gz"
      sha256 "9d3fce8139bbbed0e99592c0085361b23945077b020e403e96bab2f89f18d116"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.114/agentshield_0.2.114_linux_arm64.tar.gz"
      sha256 "05c1f263caacd71612004fdb43f28e93482876ff693da2fd1ff269cef4935f8c"
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
