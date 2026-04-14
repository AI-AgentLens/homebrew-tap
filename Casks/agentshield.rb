cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.580"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.580/agentshield_0.2.580_darwin_amd64.tar.gz"
      sha256 "933cd3195b8a0e92432d525e929f48f29429b656b7248082c4da3e4c364fc397"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.580/agentshield_0.2.580_darwin_arm64.tar.gz"
      sha256 "9269b22f4861f111e349971c3abc7caa3735cf6afd97595a71ca2dd32eba6746"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.580/agentshield_0.2.580_linux_amd64.tar.gz"
      sha256 "dd6a020ace369c6fa6ed4785bab88db389cc55839250e6d773879ff6b395b8e5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.580/agentshield_0.2.580_linux_arm64.tar.gz"
      sha256 "6e0f46bf9411e3baf2bfe04d35462f9a5041465600b69f40cf99fa956c73b9d8"
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
