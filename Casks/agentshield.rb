cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.848"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.848/agentshield_0.2.848_darwin_amd64.tar.gz"
      sha256 "9e3df3f42dbbbde14a71ae4c63bfc8a3ae74105cfdaac66522e24763ef5cabdf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.848/agentshield_0.2.848_darwin_arm64.tar.gz"
      sha256 "8c24d18c87b4f0a51f11f34176c7ef6bcc5b0d79188e242451bd83d8df108088"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.848/agentshield_0.2.848_linux_amd64.tar.gz"
      sha256 "a79de7119c5f414258ecf2eb93ed5b1044e6e3f9a1cab7cdf3363ac9295ecf9f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.848/agentshield_0.2.848_linux_arm64.tar.gz"
      sha256 "0e87c074bbbb7f076c7f36b5ff5184b3c1f8efcfece1933415ab3a4b96b7b022"
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
