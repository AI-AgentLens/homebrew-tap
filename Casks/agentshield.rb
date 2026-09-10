cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2104"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2104/agentshield_0.2.2104_darwin_amd64.tar.gz"
      sha256 "45be90b7d551bfb3e7087a04cf6ae9e6f161529db076b9c712efbbf5d72dda12"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2104/agentshield_0.2.2104_darwin_arm64.tar.gz"
      sha256 "83f6b90f44c1e236c5c1b7e91a3f7726233eed186c57994f666034e2a7fbb5b7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2104/agentshield_0.2.2104_linux_amd64.tar.gz"
      sha256 "f8b674bd2689a702d77609da6a6bc9ba246322189f709fa41d61b8696f1ded4d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2104/agentshield_0.2.2104_linux_arm64.tar.gz"
      sha256 "83e697745ed370f005a6dbdcc1602b8a1e6680b81fe57bf21291a7eeafbf68e5"
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
