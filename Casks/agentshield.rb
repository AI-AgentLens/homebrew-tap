cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1428"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1428/agentshield_0.2.1428_darwin_amd64.tar.gz"
      sha256 "26868a5353669f6ab83db1c229df5f0a4386d7020023987cab9f2fcfcd669d60"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1428/agentshield_0.2.1428_darwin_arm64.tar.gz"
      sha256 "bfc55325fb1e8da88da7efb1cbba893b02bd9f40a3b7425fa416d69dc510d77b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1428/agentshield_0.2.1428_linux_amd64.tar.gz"
      sha256 "44755790f8be51c7f5419a7cf7ca187b72c86bc48e00e91e6d938f3f535fad9c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1428/agentshield_0.2.1428_linux_arm64.tar.gz"
      sha256 "4542a74e2b77c21edb51b567ff60b90084f5b93bdbe190ca7fec65cb40d4cd8e"
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
