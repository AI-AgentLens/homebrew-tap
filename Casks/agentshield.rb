cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2354"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2354/agentshield_0.2.2354_darwin_amd64.tar.gz"
      sha256 "aac98b8c650d03460712a589e9409180849f2917b9231c1cdb838686626b375d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2354/agentshield_0.2.2354_darwin_arm64.tar.gz"
      sha256 "b3e32438ae5b8ed883f638ef6d8b9e88b9fbfe5d5d246aa029f631a9b214ae6e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2354/agentshield_0.2.2354_linux_amd64.tar.gz"
      sha256 "ba4663a7b3fcc34ebf5755185612fa93004d56b8bb4862b4b9d7004e7544de20"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2354/agentshield_0.2.2354_linux_arm64.tar.gz"
      sha256 "bd1fb4c54377704678ff470eeebac644f5e137f1d23334503b6f63288471c3ad"
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
