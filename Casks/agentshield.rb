cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2380"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2380/agentshield_0.2.2380_darwin_amd64.tar.gz"
      sha256 "bfe45043a6a0a85117794be42124319199b244ef1e4186f8cc3355a250a908ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2380/agentshield_0.2.2380_darwin_arm64.tar.gz"
      sha256 "f2b7bcc2a14d5cbb5019b9a9dc9f1b702dd936a16c6c4d0dfe2c410a05b9322d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2380/agentshield_0.2.2380_linux_amd64.tar.gz"
      sha256 "6ef1bee4d69b11ee96d8a745ef874cdca7fbb16ad68287d4bc66ca269fa89e9a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2380/agentshield_0.2.2380_linux_arm64.tar.gz"
      sha256 "677b7950363088f39ccc7a4ba3a4d5426db645b7b0b478ba0bc17444ddc84fa0"
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
