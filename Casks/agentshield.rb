cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1682"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1682/agentshield_0.2.1682_darwin_amd64.tar.gz"
      sha256 "9ec9c1a5b253259e729800193749409ad0dbda700bef0e06af30bf7e5f56026b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1682/agentshield_0.2.1682_darwin_arm64.tar.gz"
      sha256 "e76371d4e67ecbec0f467ede60a405113040e1d8569720e78099ea595bea6ceb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1682/agentshield_0.2.1682_linux_amd64.tar.gz"
      sha256 "5a1ce3be7f95766a5cbbed828096b2f9b8bce97b950a3552ca3578439cae4840"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1682/agentshield_0.2.1682_linux_arm64.tar.gz"
      sha256 "5f8af9ba65eb2627e575f334ec174d91135f61ffee4c921e0d67f643a5168be9"
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
