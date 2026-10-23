cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2506"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2506/agentshield_0.2.2506_darwin_amd64.tar.gz"
      sha256 "27095147463db52787db20fec2a151874c6223e150d2912b46903486eac2a013"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2506/agentshield_0.2.2506_darwin_arm64.tar.gz"
      sha256 "82260510b7b795b8337249f32a993b6fb80071860458f7ea1b4ab7004cedbe5d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2506/agentshield_0.2.2506_linux_amd64.tar.gz"
      sha256 "89e1852f52520c26ee19aa13bea8896d0cd715ee332aebbb1997b7084f1af130"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2506/agentshield_0.2.2506_linux_arm64.tar.gz"
      sha256 "986325c9450c4510413f332fe1362215078ed5d1da1dacd2114b059251057760"
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
