cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.876"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.876/agentshield_0.2.876_darwin_amd64.tar.gz"
      sha256 "7c9c84083d12a3579444f1d5ef7209295b23ea852c32278e00387a430bb58a01"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.876/agentshield_0.2.876_darwin_arm64.tar.gz"
      sha256 "3fbcebad077afcc71c717c0a1404c290f7358636e605b115a4ff680becf14171"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.876/agentshield_0.2.876_linux_amd64.tar.gz"
      sha256 "9a33b07225de50177aff4660164fa6d8fcbaa85a00c1b5319bf58d91e98b3189"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.876/agentshield_0.2.876_linux_arm64.tar.gz"
      sha256 "2fae79719dc604a2914336fad061277042be9ff3c4c53e8950a761bcaab4cb55"
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
