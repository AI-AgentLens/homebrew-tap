cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2427"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2427/agentshield_0.2.2427_darwin_amd64.tar.gz"
      sha256 "1dc165ed112f5cc227af92d72dee9a92c1edf721a755f22b45e3133a1d3fdbcb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2427/agentshield_0.2.2427_darwin_arm64.tar.gz"
      sha256 "7e5f079981a3e15826114406b358ba62a07e7352597fba7a4d9409c41db169cf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2427/agentshield_0.2.2427_linux_amd64.tar.gz"
      sha256 "1e4f4876f7e5b09bd7dc6ff57db75be6d92f856ae18164ffbcc6c342796dc76d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2427/agentshield_0.2.2427_linux_arm64.tar.gz"
      sha256 "fb3bcac29dfe899d18889a96cafb7f2067197d68629697125de00a99ef17dc0e"
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
