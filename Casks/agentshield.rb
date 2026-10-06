cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2356"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2356/agentshield_0.2.2356_darwin_amd64.tar.gz"
      sha256 "113d8fcf9f89ce9f51a85be7e4ad6c3dc0aecd255171ccc198ee158b5bc4ef49"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2356/agentshield_0.2.2356_darwin_arm64.tar.gz"
      sha256 "bc9f18717ba7fb84449ec344fc708e21d767e51abe4c20d8a7396eeebe2b4069"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2356/agentshield_0.2.2356_linux_amd64.tar.gz"
      sha256 "8ec7d9b74b20941b97c14bbe6590c6812d9360e22e1b37a54e243813cb9dc815"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2356/agentshield_0.2.2356_linux_arm64.tar.gz"
      sha256 "a968152f16fcebf312dbabf88b7cd1be53c92913cd7d5dcb0d122bc99d80c1f7"
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
