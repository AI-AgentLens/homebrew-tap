cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.448"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.448/agentshield_0.2.448_darwin_amd64.tar.gz"
      sha256 "f66b6fa7952a1af167d795c587a0646e3016e1eeba4223c4a01df21bdd6b43d7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.448/agentshield_0.2.448_darwin_arm64.tar.gz"
      sha256 "20b10f7ad87f3d86becd097f09bb6184ec3f7498be259f0c67d33f461c3e31d4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.448/agentshield_0.2.448_linux_amd64.tar.gz"
      sha256 "7928ae2a7cab4b9571e8d9dc729c2e6a0bb57eaa8151bcd6be2a6bb11ac513f9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.448/agentshield_0.2.448_linux_arm64.tar.gz"
      sha256 "c2663cd42f0a9e013ed690736adc71dbeb1850a13874a1c418fb4ebd4dfc1783"
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
