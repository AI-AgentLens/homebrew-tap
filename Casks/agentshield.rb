cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.220"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.220/agentshield_0.2.220_darwin_amd64.tar.gz"
      sha256 "0c09af08d4fb059df8445fca537793158cd601e43044244047faaf2511726f0d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.220/agentshield_0.2.220_darwin_arm64.tar.gz"
      sha256 "2bca6eb5c6efd3887722b4c3034e8e269d79e643a80a582af241107fac843ab8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.220/agentshield_0.2.220_linux_amd64.tar.gz"
      sha256 "a335d837f8e21a0a75efc2aa41854959bcfbdd66547f50b8cde030a4f566a628"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.220/agentshield_0.2.220_linux_arm64.tar.gz"
      sha256 "0103bbab4d2a3fbac42f5967b1a850c63257fc9425b8f0e3b50ef7db7658c75b"
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
