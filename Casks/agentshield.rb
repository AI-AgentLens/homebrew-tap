cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.828"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.828/agentshield_0.2.828_darwin_amd64.tar.gz"
      sha256 "326e1dde5d5af2d42c26733b594f8583495c9016884b5411d721ad9773d35cce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.828/agentshield_0.2.828_darwin_arm64.tar.gz"
      sha256 "2cf59c27b04f13c7e2f0d75ea3cd724fe978e215072f05e9c2d73a0358f82ffe"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.828/agentshield_0.2.828_linux_amd64.tar.gz"
      sha256 "5afe1397a1b52765452a96916a2de7daabcacd41b8039cecba1a481ba0e124ef"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.828/agentshield_0.2.828_linux_arm64.tar.gz"
      sha256 "c8fdb53e87437888f2b5b5562fd42a34888d52a96255606c858ba72130588dd8"
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
