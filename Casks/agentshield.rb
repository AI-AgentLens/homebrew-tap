cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.558"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.558/agentshield_0.2.558_darwin_amd64.tar.gz"
      sha256 "2b6f52252ec04bfea069dfa29f93a3b4a538e2977e3e820bf8fc0abd43ed1336"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.558/agentshield_0.2.558_darwin_arm64.tar.gz"
      sha256 "cc7607acede8273f3df5157b08bb2e69d006a27ca0d0e6cde3dc681d2322dc94"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.558/agentshield_0.2.558_linux_amd64.tar.gz"
      sha256 "838658fdecf17beb5475c90837ba29da1088d0e84b8be6ac0c3c4e56a8dfbc52"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.558/agentshield_0.2.558_linux_arm64.tar.gz"
      sha256 "03aa61b0561ddc18196a476661cc644462316f3dfd314bc6e2cb3fbaaef8f040"
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
