cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1643"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1643/agentshield_0.2.1643_darwin_amd64.tar.gz"
      sha256 "e10dfee1003310ef723e1e967cea2c6eedc740a73482b4a4948bd23d91a8016f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1643/agentshield_0.2.1643_darwin_arm64.tar.gz"
      sha256 "dfb21cada0024f2770d18ac7b01aa955c9f2a137e8a744f16c8755b7fef8878e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1643/agentshield_0.2.1643_linux_amd64.tar.gz"
      sha256 "496c27746863396d893d2e297b17bcbc365d2452ad24ae6028befc7a843785f2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1643/agentshield_0.2.1643_linux_arm64.tar.gz"
      sha256 "cb6603cd4d71a279f5bb692643748a2252e787a23896510463f0c454161e889c"
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
