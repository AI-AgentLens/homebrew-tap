cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2366"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2366/agentshield_0.2.2366_darwin_amd64.tar.gz"
      sha256 "a091bf297d8f606d1f2f8905721e343ba046a4785514a36aa42dd1c8c4f1377b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2366/agentshield_0.2.2366_darwin_arm64.tar.gz"
      sha256 "0d2445758e4a7fd2bd1032475dcbb2e64362574c176b52638cab5682f389e20d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2366/agentshield_0.2.2366_linux_amd64.tar.gz"
      sha256 "e38355f96825bc325423f74881e5f9e87a14e5bbda3dc48d4efb94982cfad9f3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2366/agentshield_0.2.2366_linux_arm64.tar.gz"
      sha256 "6cb7b5c19dcdb0a46840b35fa0fcd2eb6e5faa0d0005007e13e11c1725203ef0"
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
