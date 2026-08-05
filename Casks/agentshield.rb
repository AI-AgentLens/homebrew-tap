cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1789"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1789/agentshield_0.2.1789_darwin_amd64.tar.gz"
      sha256 "f7eec58ff11d74fe05278aeaa9895e08404d8031ad88dadf451b503971b2d1c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1789/agentshield_0.2.1789_darwin_arm64.tar.gz"
      sha256 "dfe7f162dae514cbc81a37da4656a12cbdb57f2215da9ea384a8912654477a42"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1789/agentshield_0.2.1789_linux_amd64.tar.gz"
      sha256 "9fab28426c1de515117a82fd10f98559c4ab374ea33bee4d45de7a83769a57a8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1789/agentshield_0.2.1789_linux_arm64.tar.gz"
      sha256 "ccc1e8a9554866d0b146467959d2690bef22925c6ca0dd9746275ec32ef7de38"
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
