cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1970"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1970/agentshield_0.2.1970_darwin_amd64.tar.gz"
      sha256 "36c872d179d8dec443ec3855d38d7ef0c73a5ea942c7b1ba660bb1d10639b22d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1970/agentshield_0.2.1970_darwin_arm64.tar.gz"
      sha256 "f2d4fc792f2e61de4682ab295d27894f5ae703fc8de4f55fc62671248f2eca65"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1970/agentshield_0.2.1970_linux_amd64.tar.gz"
      sha256 "243e2903be2251c9506203fc4d2a602b654abc1c7557f6f99cf7bc124f81bcf3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1970/agentshield_0.2.1970_linux_arm64.tar.gz"
      sha256 "f4c8ade0f621fdf731f13ec72393175cb1dd47488fe6570cbff695effcaf6fc5"
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
