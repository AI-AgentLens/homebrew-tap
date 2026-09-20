cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2200"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2200/agentshield_0.2.2200_darwin_amd64.tar.gz"
      sha256 "e1ff718547b23c93806233fd676e136aaee7f0a7454c0ba6564608a7e4319c17"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2200/agentshield_0.2.2200_darwin_arm64.tar.gz"
      sha256 "08081ec4a8e9ec2139219f8e9fdc62c6780b1a681541b65d96abe8526209dc4b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2200/agentshield_0.2.2200_linux_amd64.tar.gz"
      sha256 "6d3517ad362ac74a566f4144bec2d5c173b66416f99ec25e887e75a7a6f286c0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2200/agentshield_0.2.2200_linux_arm64.tar.gz"
      sha256 "9b7116175699bf75bd68c50239aa61abbcec418fc6910832b9649c8fb75ee49e"
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
