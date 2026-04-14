cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.585"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.585/agentshield_0.2.585_darwin_amd64.tar.gz"
      sha256 "88326e506c79a56758cb09c43119c45d299f33f56fc1c3c52d231286d61d32e6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.585/agentshield_0.2.585_darwin_arm64.tar.gz"
      sha256 "1886bfc8febe591d149701d6641cda8c8b9be0a15c7b84974e370fe9fce8feaa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.585/agentshield_0.2.585_linux_amd64.tar.gz"
      sha256 "a3920edf1f119bb9f1131b85a4c514a1af52db628afaa7230a8137f75b2dc908"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.585/agentshield_0.2.585_linux_arm64.tar.gz"
      sha256 "4727467ee104a52a0120cf8229c49cc3a4545146ee87ea917188bb83ca48cbaa"
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
