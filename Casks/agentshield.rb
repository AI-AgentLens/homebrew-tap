cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2276"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2276/agentshield_0.2.2276_darwin_amd64.tar.gz"
      sha256 "d9e529ac5b0f0c3ce8fd80ecc378f00db13951baf75f6ef79e04b9b5b7e949d1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2276/agentshield_0.2.2276_darwin_arm64.tar.gz"
      sha256 "7277fd5bf85a4d6fb0e0a7e5b9ef95ea000f54b38ba1282afad5c00f58b32deb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2276/agentshield_0.2.2276_linux_amd64.tar.gz"
      sha256 "cfcdb827b7ee1fb5b056087c906ac1be9ffc86b47461267d1dec6566a22f30e5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2276/agentshield_0.2.2276_linux_arm64.tar.gz"
      sha256 "59ce541b6f481e46a2b70e4ee6872d3a54c9b7e7c440dad7c463f0b297e38bac"
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
