cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2273"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2273/agentshield_0.2.2273_darwin_amd64.tar.gz"
      sha256 "86da31fc5c5df443c11b6e8b8c00668d5cc9d7db0cc2f2906c134da603ea977e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2273/agentshield_0.2.2273_darwin_arm64.tar.gz"
      sha256 "bc4c8173bfaae08295824bad9cc1826fa794b3810347c58b0aa9a3e12ce876fa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2273/agentshield_0.2.2273_linux_amd64.tar.gz"
      sha256 "3d5d814ce4dcd8f987a8d52b936d455284fec9e315e5a95bd92e6ddd616ceea5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2273/agentshield_0.2.2273_linux_arm64.tar.gz"
      sha256 "1304e7102f94d6f19f6791a6c86f4bf029c772de495f0ddd1952fd8760d3949f"
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
