cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.267"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.267/agentshield_0.2.267_darwin_amd64.tar.gz"
      sha256 "2431c2b2d23b307405fa948c851f803308ad42c4b44f06d9c7386d1d2337725b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.267/agentshield_0.2.267_darwin_arm64.tar.gz"
      sha256 "805bb820f577cadd5e4d612ac736183b23db15c4357eb6d5b23c2a881d8dfe14"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.267/agentshield_0.2.267_linux_amd64.tar.gz"
      sha256 "ece11dcf279939621d353a119fffa14c000634443f9f7f3c3abf6c1e2c2fbc16"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.267/agentshield_0.2.267_linux_arm64.tar.gz"
      sha256 "c8b30f6873da4618a8ad57df1d12cbfac38065764bbb61b267a3277c955552b3"
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
