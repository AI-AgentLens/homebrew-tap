cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1829"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1829/agentshield_0.2.1829_darwin_amd64.tar.gz"
      sha256 "5d61fe0ea85d86e6a0e5e21c24efb3ccb851eb37460656f5472f122cc170a5e6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1829/agentshield_0.2.1829_darwin_arm64.tar.gz"
      sha256 "03a7fade123246709681f0dfcf7c3ab8ed57daa188160ce8c1fd1674004c1de5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1829/agentshield_0.2.1829_linux_amd64.tar.gz"
      sha256 "973327020b7262a2662a1c8cf833ac54d8d4cf6935a06f8ef2361ec66be97834"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1829/agentshield_0.2.1829_linux_arm64.tar.gz"
      sha256 "d0b41a8f032bebd78576220e5fb4203b86ac1d37e5bdb49c6bdf271ab4476f46"
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
