cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1252"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1252/agentshield_0.2.1252_darwin_amd64.tar.gz"
      sha256 "2b1866580017d05a9afd992312e2d168d2f92371b82de9947329aa35757369c8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1252/agentshield_0.2.1252_darwin_arm64.tar.gz"
      sha256 "0aa3fe4ab48a36dd778f507c459b7b15e46a23f940eb77c20ade1143933c784b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1252/agentshield_0.2.1252_linux_amd64.tar.gz"
      sha256 "1b581c9dbdde6293538df73f95687f69ff03ca1e66f2945a1386879032bfda82"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1252/agentshield_0.2.1252_linux_arm64.tar.gz"
      sha256 "d02193b57021c9e01583cfcaa48b3e716c20e3d3826f3a9b50982056dcc60a39"
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
