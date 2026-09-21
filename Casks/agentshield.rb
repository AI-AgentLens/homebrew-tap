cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2208"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2208/agentshield_0.2.2208_darwin_amd64.tar.gz"
      sha256 "dbfafbcec2a658b7903e3b5215e24ba70321a4c5e578cf86d2634acc1eb5de8f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2208/agentshield_0.2.2208_darwin_arm64.tar.gz"
      sha256 "990a6b366bc81d7ac697c9509474056b805bdbe6900b98b2adfaab39bc3fddf1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2208/agentshield_0.2.2208_linux_amd64.tar.gz"
      sha256 "7878e0cf07484818be0ea9901901fdc056022df82c1d70368e6a94aa2d00b4cd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2208/agentshield_0.2.2208_linux_arm64.tar.gz"
      sha256 "338c143847752c8e6ba4dcfed5ea7492c9b3b343ff859b653b422ed164c9276b"
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
