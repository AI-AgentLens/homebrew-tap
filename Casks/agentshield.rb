cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1045"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1045/agentshield_0.2.1045_darwin_amd64.tar.gz"
      sha256 "166fda50473802a97c0f75e87ae8f979a9ca5688cec4888486ee4731fa42099d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1045/agentshield_0.2.1045_darwin_arm64.tar.gz"
      sha256 "849cdeb67c0a7f8c8098596fc042bf33bb0ad2ca72161ef865b23dc1482fbb3c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1045/agentshield_0.2.1045_linux_amd64.tar.gz"
      sha256 "1cd83d227b6b6b67070538e17c2e5d827b56b80953c49f507f92abd08d6da54c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1045/agentshield_0.2.1045_linux_arm64.tar.gz"
      sha256 "1b52533a2f8b522fa04e3b3b217e166a0a53603fabdee3bcbefbb487e9fac21a"
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
