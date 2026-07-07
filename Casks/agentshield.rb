cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1579"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1579/agentshield_0.2.1579_darwin_amd64.tar.gz"
      sha256 "0ac932aa13cafe0eac7afd181ec346488979b9dd33fc4289cdc5f3e5db304e7b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1579/agentshield_0.2.1579_darwin_arm64.tar.gz"
      sha256 "aefb4dc3b0f39d1e787875b74e5755b8b58e16f047ecaad04ddb5ace2cc2f8a6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1579/agentshield_0.2.1579_linux_amd64.tar.gz"
      sha256 "60f16b267730a01bb2af9e264caf573a765658196c4cae33089b4bcb7d164fea"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1579/agentshield_0.2.1579_linux_arm64.tar.gz"
      sha256 "cdc30fcbbf3d0f89ea3571d0463f80343abd0390aa0f8424516f4432cf62a5e5"
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
