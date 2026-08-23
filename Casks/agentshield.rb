cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1940"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1940/agentshield_0.2.1940_darwin_amd64.tar.gz"
      sha256 "1d87e92e217719fed12d403e0e8c00a7ee9a9a91e725adf29c8f286accc17a81"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1940/agentshield_0.2.1940_darwin_arm64.tar.gz"
      sha256 "97f5da34512ab7a78d821d060cdf0807d92744edffad78da8309f6df14da2589"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1940/agentshield_0.2.1940_linux_amd64.tar.gz"
      sha256 "6fe8773af9651f1a3865383fa315af46f59155557248969964b76611582be92b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1940/agentshield_0.2.1940_linux_arm64.tar.gz"
      sha256 "7eb43132b27799f16a02faa1bae98c92ed162296a880c7ceab7bf40a532b498b"
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
