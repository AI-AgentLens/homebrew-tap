cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.901"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.901/agentshield_0.2.901_darwin_amd64.tar.gz"
      sha256 "2379e194ff0cfad53f01dfc8ab855dc26fd541aa480d660670eeb2bb62d94f16"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.901/agentshield_0.2.901_darwin_arm64.tar.gz"
      sha256 "ee8fd78e7d13a22caae131fbc9b48b01aac2aee8fc0d073dc784ab31df790b95"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.901/agentshield_0.2.901_linux_amd64.tar.gz"
      sha256 "e43b49d3921108b78744d92a4658b64f9ebecabcd98397028aede1b7fdb84deb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.901/agentshield_0.2.901_linux_arm64.tar.gz"
      sha256 "d6de732cdbb1eda13e859b56b38f848925f5b761dc9e8a310c41ecb9c2c2d63f"
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
