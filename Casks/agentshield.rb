cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.965"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.965/agentshield_0.2.965_darwin_amd64.tar.gz"
      sha256 "25c43e61d58ad81acf86bf43dcc32ae09aeb286c7e622b36090cc72dec842e78"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.965/agentshield_0.2.965_darwin_arm64.tar.gz"
      sha256 "84a021630f3d73dec04d8994b22892ef876cb11d2e0424e51c19af14ed4432e5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.965/agentshield_0.2.965_linux_amd64.tar.gz"
      sha256 "55699cd5839a206a835803b229f7ab31956782f6f392f5b07ae949d06a1e7592"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.965/agentshield_0.2.965_linux_arm64.tar.gz"
      sha256 "dacb0f7f33bfd0faf2185185d3bbd0c72d429fc7bd42694d31c862fab8673c1c"
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
