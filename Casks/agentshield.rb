cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1656"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1656/agentshield_0.2.1656_darwin_amd64.tar.gz"
      sha256 "961c0a9e7e67d4bd9c2c10ee3648d956da0c42427a95c90eaeae5ed8c9681eb6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1656/agentshield_0.2.1656_darwin_arm64.tar.gz"
      sha256 "27c734930754258ccaaed0afc98a31afb7a8c1a163008f290c566b95ce055078"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1656/agentshield_0.2.1656_linux_amd64.tar.gz"
      sha256 "57eb26221a351b4bf619cef62739aa474e034a9c930181899f8fe9934481ce8d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1656/agentshield_0.2.1656_linux_arm64.tar.gz"
      sha256 "6d73f85efdc5c0d5346552f19b791669ee59b6f11d4d168db2800f43eb016d31"
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
