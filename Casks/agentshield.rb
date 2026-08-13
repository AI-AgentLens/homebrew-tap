cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1843"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1843/agentshield_0.2.1843_darwin_amd64.tar.gz"
      sha256 "8dc0e7203c122b0d166f54950cdbd556596bc47a6d27d88d2a11aec8eb4402b0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1843/agentshield_0.2.1843_darwin_arm64.tar.gz"
      sha256 "a2d255a52abe0453bb9d6898ef32118393643959d465286018d95d1cd4b86331"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1843/agentshield_0.2.1843_linux_amd64.tar.gz"
      sha256 "79307af9c5db702581c950c805065c26a0c2879e09e029c9e5a672f52794c65d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1843/agentshield_0.2.1843_linux_arm64.tar.gz"
      sha256 "f2b38174435aceb70ea2d853753afcf7bfbf4fac7cb39ad317c85ed880397f67"
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
