cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1301"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1301/agentshield_0.2.1301_darwin_amd64.tar.gz"
      sha256 "f5f6f4ffb2a85b9e67cad550e767a9f88663a9cb4687dfe65f5007be81a1d6a4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1301/agentshield_0.2.1301_darwin_arm64.tar.gz"
      sha256 "d53d01e95360669327c2e4b2af31d34cad3c7b34fb5414bb46ec52535592f8bd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1301/agentshield_0.2.1301_linux_amd64.tar.gz"
      sha256 "4831f6dcc9759eebb6e3967574070d6b89456a4cdfa9b62aefc4c393cd81415d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1301/agentshield_0.2.1301_linux_arm64.tar.gz"
      sha256 "d0aaaa5ac98053e1490f1c43380942d75bbffebc7121c1a86c945bd230734632"
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
