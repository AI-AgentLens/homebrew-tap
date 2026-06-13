cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1308"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1308/agentshield_0.2.1308_darwin_amd64.tar.gz"
      sha256 "03b2fd88bb7332ef5b61f8ac2198d95130c91f6a5386cae9573908421122438d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1308/agentshield_0.2.1308_darwin_arm64.tar.gz"
      sha256 "7faf65f6622f3730524c5976eadbd4e2e231b9be10304081cfc79e3e10fc8c24"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1308/agentshield_0.2.1308_linux_amd64.tar.gz"
      sha256 "5219be104ad266e1520fa5325e7aaf02d747006191feef409f3470b692d9d1ef"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1308/agentshield_0.2.1308_linux_arm64.tar.gz"
      sha256 "e9cef4b30ba867fa469a05e588195a20e21a9763a5c7df049166c0bdf01156d5"
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
