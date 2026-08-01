cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1773"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1773/agentshield_0.2.1773_darwin_amd64.tar.gz"
      sha256 "ad26733e47dd3f7e9dbe5c1724872b070994e572e8b1f53da81b4d7244b49b4b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1773/agentshield_0.2.1773_darwin_arm64.tar.gz"
      sha256 "57e4cee8bc74baa55c327bb882e221bdf09e2a8d50b3b8765afb416de7bab83c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1773/agentshield_0.2.1773_linux_amd64.tar.gz"
      sha256 "0a2e18acf2d38b5ef628b6ab4428e5927a4a2d7631c45dfcfdd0183e58a8547f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1773/agentshield_0.2.1773_linux_arm64.tar.gz"
      sha256 "f98e20e897e1170bc28d01d7de59332b18bd8447bb4e5ac359971818823672b1"
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
