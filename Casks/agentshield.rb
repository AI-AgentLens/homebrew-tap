cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.829"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.829/agentshield_0.2.829_darwin_amd64.tar.gz"
      sha256 "c344b73cf4b3c1030f5858c7951581917c0f6e1e18a97cbe0ed5192302b7b4e5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.829/agentshield_0.2.829_darwin_arm64.tar.gz"
      sha256 "ab2fc324930d1bcc6934b68abe1bf9cda5d462ed063feed7afc06a916e21cb22"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.829/agentshield_0.2.829_linux_amd64.tar.gz"
      sha256 "e6976ce7a2241d203dea0c3724671d0e1420c6d68d0713516695c0f9930e5985"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.829/agentshield_0.2.829_linux_arm64.tar.gz"
      sha256 "e34e69b7295fb89b653eab7b427480b9e0180839581a2b4114ac6813cce46f5d"
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
