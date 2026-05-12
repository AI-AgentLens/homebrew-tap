cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.961"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.961/agentshield_0.2.961_darwin_amd64.tar.gz"
      sha256 "81970647e1b4c1450964e7fa2f219ca4d02e7b4da6dcad3f6f1b912b49c93e4c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.961/agentshield_0.2.961_darwin_arm64.tar.gz"
      sha256 "ecfc571c45c67a6834413d01e010775b3378da48e8b1294737c1ac532e3ae895"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.961/agentshield_0.2.961_linux_amd64.tar.gz"
      sha256 "4678f18114355da9c05cf7c33227fc04ee80831d95eaab78d9ec4e3f4aeb0346"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.961/agentshield_0.2.961_linux_arm64.tar.gz"
      sha256 "0ccb1c708c27785f3d98f7a9f0e2e756e481a2332e640c5c3c207335ac4633b5"
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
