cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2360"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2360/agentshield_0.2.2360_darwin_amd64.tar.gz"
      sha256 "718072dabf7b2b23807239588a7314e479fa2305bc97c22921e602272abcca07"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2360/agentshield_0.2.2360_darwin_arm64.tar.gz"
      sha256 "9de8556c8ec8796735443f7a90c5c2e5af072532de128fa0e8f46f331bfb92b6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2360/agentshield_0.2.2360_linux_amd64.tar.gz"
      sha256 "f024e5aca9911fb48658aa71a6d5a27e32c96b3acf9efa52622ca36c41da275a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2360/agentshield_0.2.2360_linux_arm64.tar.gz"
      sha256 "f5dcee669741c45b1260812ab4a8217b87d1275f0d313b105e105173039343a7"
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
