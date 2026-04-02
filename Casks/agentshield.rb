cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.319"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.319/agentshield_0.2.319_darwin_amd64.tar.gz"
      sha256 "5970a1ad3c27e0b5cbe6f02ed6ff475129f10ef4ec81cf7179d29cd2d64eb9cf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.319/agentshield_0.2.319_darwin_arm64.tar.gz"
      sha256 "2f583bba317f4a339ebeabe286421e837743bede0db3c92ca2a68c9541fa6269"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.319/agentshield_0.2.319_linux_amd64.tar.gz"
      sha256 "8c36c1f3e418b831bc3f32221f87e58e3b75dfca0102817ab23f081d94f538e8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.319/agentshield_0.2.319_linux_arm64.tar.gz"
      sha256 "cab705781b0a5ee7276b22d66fc055538ae2c437d46bb9945ea2ec09739d33fb"
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
