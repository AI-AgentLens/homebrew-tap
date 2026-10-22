cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2499"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2499/agentshield_0.2.2499_darwin_amd64.tar.gz"
      sha256 "79f7b329056a0d14675b18ed2d06b4c7e8a0806d9a6f412854d453da2cf47163"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2499/agentshield_0.2.2499_darwin_arm64.tar.gz"
      sha256 "d801cad6f264af08a52bc0b974218b3a3d70559166dc0e67d008c1289c508115"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2499/agentshield_0.2.2499_linux_amd64.tar.gz"
      sha256 "9947d759f5e59adcc21728ae0c78bee43f10ad2442c1dc0d486e9cb32c56f886"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2499/agentshield_0.2.2499_linux_arm64.tar.gz"
      sha256 "26a23f17f4343f5c7da9f3844b4cb981d30bf56465b9505b5b6cd1446508bcec"
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
