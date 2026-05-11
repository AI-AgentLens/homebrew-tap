cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.950"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.950/agentshield_0.2.950_darwin_amd64.tar.gz"
      sha256 "6a8c2bd43bf3857076a453150f3a89ff64d4c2b38c0c8ca0904ea6a8dcb8870f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.950/agentshield_0.2.950_darwin_arm64.tar.gz"
      sha256 "654274b1263b70b71b2e5f2fc704dccb985a8bd171f606504a584c093a7d656c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.950/agentshield_0.2.950_linux_amd64.tar.gz"
      sha256 "88298a810f44295325536deb9a1533410a179d4c4bacb3172bf14546354292e2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.950/agentshield_0.2.950_linux_arm64.tar.gz"
      sha256 "d545b5706fe6abc576883d13415c5e87f5fc0659721ddf7d8ad974d102558549"
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
