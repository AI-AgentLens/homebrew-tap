cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.459"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.459/agentshield_0.2.459_darwin_amd64.tar.gz"
      sha256 "9aa7caa3967c472fe4708fe4d1ea337520d6d69d391c3a71881446332e3c5b58"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.459/agentshield_0.2.459_darwin_arm64.tar.gz"
      sha256 "c8522cb69f7242c36204aef2aa7e45086645bf1cd9d12d358450896f85e350c5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.459/agentshield_0.2.459_linux_amd64.tar.gz"
      sha256 "e7fe42c55268c2ae342097e1d3d9b305eaddac36371cb74d7b12d2d8616f23db"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.459/agentshield_0.2.459_linux_arm64.tar.gz"
      sha256 "ce4cab3b07e24a6907bc17214f4a62cccba0846464f2a557fc552a4b026f5344"
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
