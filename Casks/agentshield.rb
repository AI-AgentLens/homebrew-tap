cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1619"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1619/agentshield_0.2.1619_darwin_amd64.tar.gz"
      sha256 "131d689ce81e7a0329726a6fe38724be288b8444bd1b327893ea414277427f48"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1619/agentshield_0.2.1619_darwin_arm64.tar.gz"
      sha256 "3af16d175651be34b3fc4e0ef3ebd518315e02a419e8ff1d7fdbdfb1bbc18473"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1619/agentshield_0.2.1619_linux_amd64.tar.gz"
      sha256 "028067e92991df794bda9526a84c4e9acd730cd5d89bd851ff5941a8870626ed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1619/agentshield_0.2.1619_linux_arm64.tar.gz"
      sha256 "ba67bc7dd024d118bf5e17005ebe221720f66477b68580f369abb3e512315d53"
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
