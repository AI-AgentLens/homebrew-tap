cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.839"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.839/agentshield_0.2.839_darwin_amd64.tar.gz"
      sha256 "934c00af487d867648b03f4b7f876d2da0d0aa7eb922a95beeab59ded5174f97"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.839/agentshield_0.2.839_darwin_arm64.tar.gz"
      sha256 "163962d9251b5404956bec5e734acc96b978e94359e96b99b2d3698ef7ec3d3c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.839/agentshield_0.2.839_linux_amd64.tar.gz"
      sha256 "6951dd1b03644a48a604f6de104fa6199ed343f52584765174c8cad4035fdb59"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.839/agentshield_0.2.839_linux_arm64.tar.gz"
      sha256 "967062c16affa286794fb776b51df06e179cf2352d29965dfad44aae519e7a04"
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
