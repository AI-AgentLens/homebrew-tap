cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1651"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1651/agentshield_0.2.1651_darwin_amd64.tar.gz"
      sha256 "3bda65187afcaf0ced3842fc9d43df59331bb719077687d89a078e569ddc2375"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1651/agentshield_0.2.1651_darwin_arm64.tar.gz"
      sha256 "ab3ef1b53ba689717a16c91cd976285af2fb3eade578912e8f542cb8368a8e78"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1651/agentshield_0.2.1651_linux_amd64.tar.gz"
      sha256 "0ff02831a61d2518bfd1375985c9be2a644d102d99b08874dd4c6fc50a7e12ca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1651/agentshield_0.2.1651_linux_arm64.tar.gz"
      sha256 "8cb84bd7d5ce19ffeb333a718feb32c8bd04dc0a841f0ff1617a8cfc3998eab4"
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
