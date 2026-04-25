cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.722"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.722/agentshield_0.2.722_darwin_amd64.tar.gz"
      sha256 "74964e61bdf7f7b05944b9453ed6ae4ec3727381781bda4021e51850a3d8cd58"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.722/agentshield_0.2.722_darwin_arm64.tar.gz"
      sha256 "b0238be78a33a0e2f199b13faec8b7d20bf9b815e9a0e0b33963e2e8fe38d335"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.722/agentshield_0.2.722_linux_amd64.tar.gz"
      sha256 "7e45c2d889032a0bcdc54c6ce2f0459265d993c8150ac580a2dd5af967777be7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.722/agentshield_0.2.722_linux_arm64.tar.gz"
      sha256 "0963fd7e49502a075261c8d8661cf40896bcaf81af19232081e5f8d8b365bebd"
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
