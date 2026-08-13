cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1847"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1847/agentshield_0.2.1847_darwin_amd64.tar.gz"
      sha256 "3433c0fd9537b9478a5bf1d68496fa22ca0c2ce483f39ea077b4116f1b17c79c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1847/agentshield_0.2.1847_darwin_arm64.tar.gz"
      sha256 "78a702833fa56665b7078d33f62541c7ef340314120020739c1854ab4e4e1f12"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1847/agentshield_0.2.1847_linux_amd64.tar.gz"
      sha256 "e1706e2165e63eed81ae6ba8a78ce06508fc6ea9a60b7b7878088dc43160d105"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1847/agentshield_0.2.1847_linux_arm64.tar.gz"
      sha256 "f100956f20ca5c566367cab118092822ab9e92812ec4c12ff0e98c4700990e57"
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
