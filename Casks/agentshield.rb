cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.266"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.266/agentshield_0.2.266_darwin_amd64.tar.gz"
      sha256 "7a31b597becdd6f5452ea14a2d4ac0116826954665468a7c59f73ac55c697868"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.266/agentshield_0.2.266_darwin_arm64.tar.gz"
      sha256 "c9de7773f39931ea0547c9a376277cb5922b44eedbbd9d3f9d80199086db3100"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.266/agentshield_0.2.266_linux_amd64.tar.gz"
      sha256 "570c18af77aa1226cde349039bf4e00b44e0efa3da8c39bca362efebd8b09709"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.266/agentshield_0.2.266_linux_arm64.tar.gz"
      sha256 "33ff4c176240b14a142b975acc348894e919717f7e8476d78756ec3968125fd4"
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
