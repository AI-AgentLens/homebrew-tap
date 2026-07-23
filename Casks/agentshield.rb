cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1715"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1715/agentshield_0.2.1715_darwin_amd64.tar.gz"
      sha256 "94faae5960d0288780c041ca8a7a3d08dfd7cd8c24608c45e0100da712fa8c7f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1715/agentshield_0.2.1715_darwin_arm64.tar.gz"
      sha256 "4d8c20919f1c2b965b0dd2c265a49516a820b5bf0175484b23adf8bf3fbd0a79"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1715/agentshield_0.2.1715_linux_amd64.tar.gz"
      sha256 "c72277abb7a14527e9c8ae772d5afbd3af76efa20de75c384296e71613b5f9ff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1715/agentshield_0.2.1715_linux_arm64.tar.gz"
      sha256 "95351d30b50e9304d8757e56f2cac5668c7c03eb7aa1f92508683659a5b2ffd2"
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
