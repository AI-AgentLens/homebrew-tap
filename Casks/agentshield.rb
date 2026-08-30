cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1988"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1988/agentshield_0.2.1988_darwin_amd64.tar.gz"
      sha256 "153e5cffc47b617d700b10b8e86498c603336b477224a8db6d6e0559905a9879"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1988/agentshield_0.2.1988_darwin_arm64.tar.gz"
      sha256 "feede685730f48aa25c3d13fae6c2507172b75bc811df710d9b0dcf6342a1400"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1988/agentshield_0.2.1988_linux_amd64.tar.gz"
      sha256 "2f73ff6d5c95cfbaf4f9924d1f77b1b92dc5c3f8e2bf9919faff52d9900383c9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1988/agentshield_0.2.1988_linux_arm64.tar.gz"
      sha256 "dc2342921c5927eb9c671987d4d331a11bd4dde9ec126eca6eb68cd8e3e9a589"
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
