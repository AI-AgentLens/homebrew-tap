cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.946"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.946/agentshield_0.2.946_darwin_amd64.tar.gz"
      sha256 "5b475e9895d31c10aadf62e9ba015a11d17ac7976dd92c0acc0428ad30cf7a78"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.946/agentshield_0.2.946_darwin_arm64.tar.gz"
      sha256 "448411c694335353e86e1ef3afa5b5a3f292c792d19188d75cb2afdd30d6982e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.946/agentshield_0.2.946_linux_amd64.tar.gz"
      sha256 "656bf75c194e95742edfc2d840d05702246e61b0bf870850509f69c6eb6486e5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.946/agentshield_0.2.946_linux_arm64.tar.gz"
      sha256 "1178680a42e3c5831eb3f84cc3df7604b6ad9e068b5fb777131ef7328f46f299"
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
