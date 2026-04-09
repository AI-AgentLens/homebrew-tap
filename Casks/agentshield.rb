cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.508"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.508/agentshield_0.2.508_darwin_amd64.tar.gz"
      sha256 "1c00f52b7a1927fb54a6bc0342a8ae89c04adf0d36d648a6fdb06733f021914a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.508/agentshield_0.2.508_darwin_arm64.tar.gz"
      sha256 "1ee2ac97b597487cea8b37b2f3aa64347a68dc53bccf4f821c0adcfd5f23cf5a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.508/agentshield_0.2.508_linux_amd64.tar.gz"
      sha256 "1a81c339cfcd974542b56a333f1237a7b4ca3c7eb8f2545521a7f662bac7e1ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.508/agentshield_0.2.508_linux_arm64.tar.gz"
      sha256 "d192a63887637bea9ae7a5c37f44e94a7c743afcaf2c8001156657b7e09ec61b"
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
