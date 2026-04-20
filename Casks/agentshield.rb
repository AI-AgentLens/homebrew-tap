cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.666"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.666/agentshield_0.2.666_darwin_amd64.tar.gz"
      sha256 "970cbe27d9d00d05986d1e6a53a3c09038d7bdc47763a54cd0131c871df8e3a9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.666/agentshield_0.2.666_darwin_arm64.tar.gz"
      sha256 "e5209f7c8c6dd49614df9eb708149f781292537194e99dc547854d36a67df7e8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.666/agentshield_0.2.666_linux_amd64.tar.gz"
      sha256 "88ef780e01d68480c6ccbc1204e43de4cd0a05f7b852cc08231c8c9e836ce99e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.666/agentshield_0.2.666_linux_arm64.tar.gz"
      sha256 "08083b31f85e8a40098c4fa6135ba43bbb7c9a8a4828ccffa81b34f5182b571f"
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
