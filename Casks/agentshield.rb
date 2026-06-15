cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1321"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1321/agentshield_0.2.1321_darwin_amd64.tar.gz"
      sha256 "7fe38f332493e3e5cecded836d09c7a1d0738fcc116c352d8783747c5441c03d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1321/agentshield_0.2.1321_darwin_arm64.tar.gz"
      sha256 "dc72f8023daede8a32baa4c524d26483170e7dc7aafe50cdea9b71e5dd492664"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1321/agentshield_0.2.1321_linux_amd64.tar.gz"
      sha256 "01c103bbed947cdeef29505a24cec04c1648c34c9370515b43fa1d6f0ee3fac0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1321/agentshield_0.2.1321_linux_arm64.tar.gz"
      sha256 "c1b3c0c230d3a7b2846fd47a0908ca17fe270b95326723365a622cc2d9264eb0"
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
