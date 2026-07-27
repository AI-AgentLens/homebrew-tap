cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1736"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1736/agentshield_0.2.1736_darwin_amd64.tar.gz"
      sha256 "cb122c2aff9da9dab9ad99ff7ff9381fd7329730c2707e55eefbb61fabded217"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1736/agentshield_0.2.1736_darwin_arm64.tar.gz"
      sha256 "786d2a4bf8fafbcc5bc3b3ff54b456c738d91ef9d7e67929445378cdfbbf1578"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1736/agentshield_0.2.1736_linux_amd64.tar.gz"
      sha256 "fddd97197874bb3fb121783fb8856cb626949b8240fc9e1efcb6c3a817cda8c3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1736/agentshield_0.2.1736_linux_arm64.tar.gz"
      sha256 "1dab91eccc20a71fbf27141b340372fded1ad6408c3c2922ea316481fc0c06a1"
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
