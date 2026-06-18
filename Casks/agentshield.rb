cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1354"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1354/agentshield_0.2.1354_darwin_amd64.tar.gz"
      sha256 "078cddcbb1cd32bd079651c12d2b54e2e29b014cc72188ef1e888b2b1c5cc5a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1354/agentshield_0.2.1354_darwin_arm64.tar.gz"
      sha256 "315ade21955c7f48acfd2893e17048dd77b1ea96936138032e5f57e7e40b0d63"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1354/agentshield_0.2.1354_linux_amd64.tar.gz"
      sha256 "65a66f19d9a9d711e0596856e8aedb0bbb48498ee2407126955ff673134f34d2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1354/agentshield_0.2.1354_linux_arm64.tar.gz"
      sha256 "d462040c31607c987c77bd94e5295c7ecb41769235abee0e89b923b63eafc560"
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
