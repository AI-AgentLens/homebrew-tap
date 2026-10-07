cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2370"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2370/agentshield_0.2.2370_darwin_amd64.tar.gz"
      sha256 "32e1ea2b5236daf41369ae74efcf07f82116764369635830bd37780099c6ca17"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2370/agentshield_0.2.2370_darwin_arm64.tar.gz"
      sha256 "83aa6d775472c68912bb2cafb48b18e6881af2a4ccb4d7457f9ef77930e97190"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2370/agentshield_0.2.2370_linux_amd64.tar.gz"
      sha256 "b97b595b4d58deb35d043bcd69f1f2f828372d77d6b7380cbf73bf938039a59a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2370/agentshield_0.2.2370_linux_arm64.tar.gz"
      sha256 "9d83fc556451f47de1562f2ca7eca1f53c2565bd36a7d9f2a4ace48859ed20c1"
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
