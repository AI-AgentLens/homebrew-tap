cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1248"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1248/agentshield_0.2.1248_darwin_amd64.tar.gz"
      sha256 "2484891b41bdfb981b7a97c5819e5a1398dc79f38c963f67cd50868e822e105e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1248/agentshield_0.2.1248_darwin_arm64.tar.gz"
      sha256 "f68c7312229551c0958ccc0325419763f871f08920c586f6e7897be45e46bd48"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1248/agentshield_0.2.1248_linux_amd64.tar.gz"
      sha256 "e17ef685a644ce601eca2b82b65beb301c36eaca9ade138763885375ac37ba93"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1248/agentshield_0.2.1248_linux_arm64.tar.gz"
      sha256 "fbfba74dab19a2fd8520b775f31d71623f0fad90ebed32fe364dbf994c36a186"
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
