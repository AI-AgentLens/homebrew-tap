cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1131"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1131/agentshield_0.2.1131_darwin_amd64.tar.gz"
      sha256 "fae96146b28f2aabf28f1a5b05767e0081b8c2ed16d469ead4165838f904af87"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1131/agentshield_0.2.1131_darwin_arm64.tar.gz"
      sha256 "6336403c87ee752e60772d6449eecedb53db4e1c055888af2ad9d7a19c5cb4d4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1131/agentshield_0.2.1131_linux_amd64.tar.gz"
      sha256 "68ec245b126bd5de7935cacd59fe95fb1368229b1e57b6b62026cf5c7d9826b2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1131/agentshield_0.2.1131_linux_arm64.tar.gz"
      sha256 "6c9a5fddd13160b448941d8023aa247e69232fc94cedc82db4b5255162dab074"
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
