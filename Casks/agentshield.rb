cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1766"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1766/agentshield_0.2.1766_darwin_amd64.tar.gz"
      sha256 "8f5dcfb0bc8084fc2d1bead6c827ca735367435ec69fb7ffed54f258df98e882"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1766/agentshield_0.2.1766_darwin_arm64.tar.gz"
      sha256 "01fef154d7ff557b43e2e49f17ef9e40312047ab7d2214a845ca409d8dffe858"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1766/agentshield_0.2.1766_linux_amd64.tar.gz"
      sha256 "bab0f7efcbc7f4ad1a6b7c93fe7a9297f61978d6ab71444b5a19c40761619557"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1766/agentshield_0.2.1766_linux_arm64.tar.gz"
      sha256 "6a3e1de8fab53845cb68ef8e5915d3b0718649f6e6bfc3365d3edddf29e9187e"
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
