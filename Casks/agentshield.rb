cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2344"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2344/agentshield_0.2.2344_darwin_amd64.tar.gz"
      sha256 "9404e9b065c6bc4d13ecc84eef29782d340a85d2ce58309451037747cde2ec32"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2344/agentshield_0.2.2344_darwin_arm64.tar.gz"
      sha256 "d1f3cbf3d25eb54a6b22134876e0451f99f6014f1edccbff62fb71cde42d3686"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2344/agentshield_0.2.2344_linux_amd64.tar.gz"
      sha256 "35b6e8ee90d681b2f61ac1f9b44d7485359fc1f4050432d74ab8549e6c05dbe8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2344/agentshield_0.2.2344_linux_arm64.tar.gz"
      sha256 "433fb66ecfeb975340478ea164b30149134afd566fbb08917ebb361079d3a4c9"
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
