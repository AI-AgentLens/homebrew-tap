cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2264"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2264/agentshield_0.2.2264_darwin_amd64.tar.gz"
      sha256 "a1fe4dbd36b55ccac5cec4425577a7109e4921895d05d8bdcffbf3d4ce86604d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2264/agentshield_0.2.2264_darwin_arm64.tar.gz"
      sha256 "afcaed498b8b7a1e927c441663bb178d47263cb06a90131caa21424f0c06b2b4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2264/agentshield_0.2.2264_linux_amd64.tar.gz"
      sha256 "8f8f78cc94f20f9e5700e5f2d6fc9c3db49e666b8fe72dd76d071d24db634254"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2264/agentshield_0.2.2264_linux_arm64.tar.gz"
      sha256 "b147049df27d0536aa79515e2221c16db5ceb982e5af39fcad45916f3772acfd"
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
