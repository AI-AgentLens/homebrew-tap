cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1407"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1407/agentshield_0.2.1407_darwin_amd64.tar.gz"
      sha256 "74b6b1f353cb58df2dc418546fca485922d111de83fe289c197fb681f6450d26"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1407/agentshield_0.2.1407_darwin_arm64.tar.gz"
      sha256 "27bf4daeab832104aaea9753425938d635737cec70b02fce0b4f384f220bf1e3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1407/agentshield_0.2.1407_linux_amd64.tar.gz"
      sha256 "030afff46ffab0950673490a2056c42f44502be39f8061c3346ab224ecf15051"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1407/agentshield_0.2.1407_linux_arm64.tar.gz"
      sha256 "d960b831559bdc4136d52e74cde0ff080448894bc0768bb529270c1ca8311b29"
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
