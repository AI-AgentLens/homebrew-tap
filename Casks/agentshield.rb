cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.940"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.940/agentshield_0.2.940_darwin_amd64.tar.gz"
      sha256 "8f8a3a503ba5046d0e7599d81501817a76428606e471d22139c33303ff23bde6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.940/agentshield_0.2.940_darwin_arm64.tar.gz"
      sha256 "df9997fbd75a4b8a81d45557275a9f98082abf7d1d59ff8ea66bbe0f6c244802"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.940/agentshield_0.2.940_linux_amd64.tar.gz"
      sha256 "8ad8d2b1227266aa9edb3581f073e58e53346644d5536c371a1339e7b09b7bff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.940/agentshield_0.2.940_linux_arm64.tar.gz"
      sha256 "73f10597c79096e91bd17cfbd06c6a001eb5dadf77015a96e2467da1ca2c99af"
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
