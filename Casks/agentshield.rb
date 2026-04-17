cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.626"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.626/agentshield_0.2.626_darwin_amd64.tar.gz"
      sha256 "f115d8b8ef8f9589f86004545428581020f6028617cdab05b2029f86c1609f68"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.626/agentshield_0.2.626_darwin_arm64.tar.gz"
      sha256 "13de88799724c51f8d79a6593475f269466afffb3be94695de1b751cce6466d0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.626/agentshield_0.2.626_linux_amd64.tar.gz"
      sha256 "d5622b0283c7fdec755241eb7e423eb6106cdf60ddd37b7ed4c14e32dddbcb2a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.626/agentshield_0.2.626_linux_arm64.tar.gz"
      sha256 "6c590168b589e3d119e6c8a3b6170fa2b492537efd76db435c51b4fd25379523"
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
