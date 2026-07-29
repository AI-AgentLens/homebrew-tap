cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1755"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1755/agentshield_0.2.1755_darwin_amd64.tar.gz"
      sha256 "336518f8b51c0ecb9157c1fe5b38de118aeb37ac25fbb6367ddfb6b970fbce03"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1755/agentshield_0.2.1755_darwin_arm64.tar.gz"
      sha256 "4cf02cace7f9dd94313fe8592fab04e73211bdbff4abfe133657a96995775ab1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1755/agentshield_0.2.1755_linux_amd64.tar.gz"
      sha256 "02b526bd25a7b98c0bdc1ff166881651c56394196300ed8533135da0e9abd5a6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1755/agentshield_0.2.1755_linux_arm64.tar.gz"
      sha256 "1c8610ac63be8c5f1bcd8a415081d58dbd72d4aa3efab62bbad78e2924dfd79a"
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
