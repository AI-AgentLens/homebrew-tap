cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2233"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2233/agentshield_0.2.2233_darwin_amd64.tar.gz"
      sha256 "92401ec7acd786d570f6d4dd326dae086ef9bbde18cae86a783f87db693b9a9c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2233/agentshield_0.2.2233_darwin_arm64.tar.gz"
      sha256 "af4178cd0ba67b597d097b5978ff2d52ce0ffdcf2e504f9fc9b51310200e82c0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2233/agentshield_0.2.2233_linux_amd64.tar.gz"
      sha256 "a4393556217b083c5214631eae3ec5dc9d31c72cdd3d7f0f8238fb37829c1f12"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2233/agentshield_0.2.2233_linux_arm64.tar.gz"
      sha256 "f97d626e559b277085568be7714a607914d5d7492c30fd49d5a7c303b0293591"
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
