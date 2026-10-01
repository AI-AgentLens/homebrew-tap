cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2305"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2305/agentshield_0.2.2305_darwin_amd64.tar.gz"
      sha256 "44a3c2d0555ab171b3460299b943f37fa6ac206831a87cd30198260bf2e5e394"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2305/agentshield_0.2.2305_darwin_arm64.tar.gz"
      sha256 "7e24ab02f2a94e702b2d9fdd0fa5b03d67743399f36b730e39d0eff9d0c02aff"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2305/agentshield_0.2.2305_linux_amd64.tar.gz"
      sha256 "0a7f5c8679d7f9ffcd8ebf45ec835a4e95e7fe6b6e1f9f0f3f56e10082d2cf36"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2305/agentshield_0.2.2305_linux_arm64.tar.gz"
      sha256 "10fac8dfd7ed2b25e969db504e8f9f8ce1ec43e51db8050bb18fb3b4c533319d"
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
