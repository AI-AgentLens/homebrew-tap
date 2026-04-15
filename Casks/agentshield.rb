cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.604"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.604/agentshield_0.2.604_darwin_amd64.tar.gz"
      sha256 "8912a6dec083887207789b67ba4f98f694452de987d8683c099fef4a59d18bda"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.604/agentshield_0.2.604_darwin_arm64.tar.gz"
      sha256 "61558a936171b5729a053a4903752dae4462c98f317d2ea927a7487e2b5383d0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.604/agentshield_0.2.604_linux_amd64.tar.gz"
      sha256 "daa232f663898960a045ea2d3d2d0431d418acb56bcbd4fa4b41625a8678d621"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.604/agentshield_0.2.604_linux_arm64.tar.gz"
      sha256 "f454da93f03bd2193007a4a073874d74a14e8bf17dbeafee7762f123dda3b76e"
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
