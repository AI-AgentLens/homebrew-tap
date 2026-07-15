cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1650"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1650/agentshield_0.2.1650_darwin_amd64.tar.gz"
      sha256 "9e19693d74beac6f48bf288e731c0ad8834652278f1dd8a426f37ba8f96f1338"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1650/agentshield_0.2.1650_darwin_arm64.tar.gz"
      sha256 "811c48ba49b5eca1c0cbf565c53301a46663852b5022335c1cff0fdb1c1b6431"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1650/agentshield_0.2.1650_linux_amd64.tar.gz"
      sha256 "63e1ddda2d9e7079d08c97fb52e21897c2d45769aeaf362df45c7c2eac63afd7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1650/agentshield_0.2.1650_linux_arm64.tar.gz"
      sha256 "654a310669d7c19c1e0cc1039c84ff977ff7688da742904df305ea7a6c507922"
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
