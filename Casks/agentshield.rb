cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.361"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.361/agentshield_0.2.361_darwin_amd64.tar.gz"
      sha256 "4ca1766d3b069d75b010e3d2999d0ea4f3c3c83999b7cee94beec2d3b0f51892"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.361/agentshield_0.2.361_darwin_arm64.tar.gz"
      sha256 "ceb499f96c56c46c3c0ed992902bbec753c82adb64f71e41ec6d2cb97adfc032"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.361/agentshield_0.2.361_linux_amd64.tar.gz"
      sha256 "63219edeb720bde671e2370a3fed7198d6af309ee5a736cac0980abba42b5171"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.361/agentshield_0.2.361_linux_arm64.tar.gz"
      sha256 "e1d7a5990ffe5db5e8b33ec32763acdee1eb1ed0954cec7a4fb043e5672cb19b"
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
