cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.613"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.613/agentshield_0.2.613_darwin_amd64.tar.gz"
      sha256 "5b1cb8ea05d764bd96640cea276e81a01662c7a6bbb1634dd1a67ffc1bf4bf09"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.613/agentshield_0.2.613_darwin_arm64.tar.gz"
      sha256 "f0f88a1121791f648d22bc5a42a495999f58389d317282914eda0d95e49b4541"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.613/agentshield_0.2.613_linux_amd64.tar.gz"
      sha256 "fe4cd7f8b209ba53a9604f43401fd416ee8171725340931f1e4070e8235b0859"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.613/agentshield_0.2.613_linux_arm64.tar.gz"
      sha256 "26052e2a7037f03cf43642722c8ba4fba0c8a7d2b7ac5d1fcdb360bfa299eab8"
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
