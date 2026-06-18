cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1355"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1355/agentshield_0.2.1355_darwin_amd64.tar.gz"
      sha256 "12a2259320becb92ed37bc38fd5a35a25ab1318d68bf987ea690a329bc75d1fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1355/agentshield_0.2.1355_darwin_arm64.tar.gz"
      sha256 "59389890201e08ed30ab638b02a2323f3605d6d2d706e32e8c3604adb96e7e27"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1355/agentshield_0.2.1355_linux_amd64.tar.gz"
      sha256 "eee6f7011f736e9dfb1166c22b1b773038656c766bb5bfea3b0abede029eec74"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1355/agentshield_0.2.1355_linux_arm64.tar.gz"
      sha256 "ec62e6c97680ff5a7924783a7aa2647ee8ea2c68e5fe72988ad359be92810de3"
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
