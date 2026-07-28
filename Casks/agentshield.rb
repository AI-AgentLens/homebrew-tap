cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1746"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1746/agentshield_0.2.1746_darwin_amd64.tar.gz"
      sha256 "5362b4c2106535e9d0195be8239160b30abd93e715763967e877651c57a8e93f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1746/agentshield_0.2.1746_darwin_arm64.tar.gz"
      sha256 "ad61d2a2db7520e53bc67240ddf6025e6751160a6abb17fd7c315123ca0edafe"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1746/agentshield_0.2.1746_linux_amd64.tar.gz"
      sha256 "b54ce02dd2bc8cf22b10e30d5ff58eec31fe65c3869b0ecea755a4a4b45c3148"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1746/agentshield_0.2.1746_linux_arm64.tar.gz"
      sha256 "5e2a949076b6770c998ff84020210e627288fe395d0e673416aa9c8233a557c9"
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
