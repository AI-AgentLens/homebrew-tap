cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2430"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2430/agentshield_0.2.2430_darwin_amd64.tar.gz"
      sha256 "c7905149e301886b3a00ee31d58172886c97e8e4343ddb1abc604c62d35b0740"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2430/agentshield_0.2.2430_darwin_arm64.tar.gz"
      sha256 "714ea356f81d5afccb0accf770ac2715204c0bfdabe29b704532029eb9bdc989"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2430/agentshield_0.2.2430_linux_amd64.tar.gz"
      sha256 "b8f9aea5dbe0c4c7a7872054f9c328039cf777e3c85803260ecb833ef4ac5774"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2430/agentshield_0.2.2430_linux_arm64.tar.gz"
      sha256 "e1823a0584e8fa5370b6bb8521a53a4f4471bb48c285b832bb71bea07689c559"
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
