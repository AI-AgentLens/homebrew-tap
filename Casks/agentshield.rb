cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.430"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.430/agentshield_0.2.430_darwin_amd64.tar.gz"
      sha256 "42decb1e5ee0e9e42394d63dbd54fbc92500f993511c212e843d257261bef00d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.430/agentshield_0.2.430_darwin_arm64.tar.gz"
      sha256 "4f1fcfb40249209d5e929ed17efccd5034109640f8be7763741de1c2cba6eeb8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.430/agentshield_0.2.430_linux_amd64.tar.gz"
      sha256 "69e1c1cdfc14e69d90133fa1eac31222dcd3c5c5419c16a2ddd5310dad8bf779"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.430/agentshield_0.2.430_linux_arm64.tar.gz"
      sha256 "10f68c937a15d55c2e1b12531cb1e3f169893cee02936aa07ef957c7dda33b14"
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
