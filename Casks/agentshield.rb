cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.263"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.263/agentshield_0.2.263_darwin_amd64.tar.gz"
      sha256 "7d1fab0052add703840ec2de72fe05def6e5bca7f34993bc77a13235874f7734"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.263/agentshield_0.2.263_darwin_arm64.tar.gz"
      sha256 "402d946524e3b1682ff4d6e7d747f2c94176ab9251868a78842ff9d181125c47"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.263/agentshield_0.2.263_linux_amd64.tar.gz"
      sha256 "5a4c015cdc1a1422e60297b03904570c2b6da344f531e59b5df2d526d679bfd1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.263/agentshield_0.2.263_linux_arm64.tar.gz"
      sha256 "e35e84a3360aa73fd7c7774d34745e65d759de07c9144cb73b1d6a6c114325e4"
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
